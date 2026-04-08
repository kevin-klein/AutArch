"""
Bottle route handlers module.
"""

import json
from bottle import request
import requests
import tempfile
import os

from modules.analysis import (
    analyze_file,
    analyze_arrow,
    analyze_skeleton,
    extract_object_features
)
from modules.bovw import train_visual_vocabulary, compute_similarity_matrix
from modules.sam import segment_image
from modules.pattern_match import match_pattern_parts
from modules.summary import extract_pdf


def download_pdf_to_temp(pdf_url):
    """Download PDF to temporary file."""
    response = requests.get(pdf_url, timeout=30)
    response.raise_for_status()
    tmp = tempfile.NamedTemporaryFile(suffix='.pdf', delete=False)
    tmp.write(response.content)
    tmp.close()
    return tmp.name


def handle_segment():
    """Handle SAM segmentation endpoint."""
    upload_file = request.POST['image']
    points = request.POST['points']
    return segment_image(upload_file, points)


def handle_upload():
    """Handle object detection endpoint."""
    upload_file = request.POST['image']
    result = analyze_file(upload_file.file)
    return {'predictions': result}


def handle_arrow():
    """Handle arrow orientation endpoint."""
    upload_file = request.POST['image']
    result = analyze_arrow(upload_file.file)
    return {'predictions': result.tolist()[0]}


def handle_skeleton():
    """Handle skeleton classification endpoint."""
    upload_file = request.POST['image']
    result = analyze_skeleton(upload_file.file)
    return {'predictions': result}


def handle_efd():
    """Handle Elliptic Fourier Descriptors endpoint."""
    from pyefd import elliptic_fourier_descriptors

    data = request.json
    coeffs = elliptic_fourier_descriptors(
        data['contour'],
        order=data['order'],
        normalize=data['normalize'],
        return_transformation=data['return_transformation']
    )
    return {'efds': coeffs.tolist()}


def handle_train_bovw():
    """Handle BOVW training endpoint."""
    images = request.json['images']
    n_clusters = request.json.get('n_clusters', 32)
    feature_type = request.json.get('feature_type', 'sift')

    try:
        vocabulary = train_visual_vocabulary(images, n_clusters, feature_type)

        similarity_matrix, valid_images = compute_similarity_matrix(
            images, vocabulary, feature_type
        )

        return {
            'success': True,
            'n_clusters': vocabulary.n_clusters,
            'feature_type': feature_type,
            'n_images': len(valid_images),
            'similarity_matrix': similarity_matrix,
            'valid_images': valid_images
        }

    except Exception as e:
        return _error_response(e)


def handle_pattern_match():
    """Handle pattern matching endpoint."""
    query_image_path = request.json.get('query_image')
    pattern_boxes = request.json.get('pattern_boxes', [])
    target_images = request.json.get('target_images', [])
    feature_type = request.json.get('feature_type', 'texture')

    try:
        if not pattern_boxes:
            raise ValueError("No pattern boxes provided")

        return match_pattern_parts(
            query_image_path, pattern_boxes, target_images, feature_type
        )

    except Exception as e:
        return _error_response(e)


def _error_response(exception):
    """Create error response."""
    import traceback
    return {
        'success': False,
        'error': str(exception),
        'traceback': traceback.format_exc()
    }


def handle_extract_summaries():
    """Handle PDF summary extraction endpoint."""
    data = request.json
    pdf_url = data.get('pdf_url')
    identifiers = data.get('identifiers', [])

    try:
        if not pdf_url:
            raise ValueError("Missing pdf_url parameter")
        if not identifiers or not isinstance(identifiers, list):
            raise ValueError("Missing or invalid identifiers parameter")

        # Download PDF to temp file
        tmp_path = download_pdf_to_temp(pdf_url)

        try:
            # Process the PDF
            summaries = extract_pdf(tmp_path, identifiers)
            return {'summaries': summaries}
        finally:
            os.unlink(tmp_path)

    except Exception as e:
        return _error_response(e)
