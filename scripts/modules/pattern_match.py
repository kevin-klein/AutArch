"""
Pattern matching module for finding similar pattern parts across images.
"""

import cv2
import numpy as np
from modules.features import extract_pattern_feature

def match_pattern_parts(query_image_path, pattern_boxes, target_images, feature_type='texture'):
    """
    Match pattern parts from a query image against target images.

    Args:
        query_image_path: Path to query image
        pattern_boxes: List of [x1, y1, x2, y2] rectangles
        target_images: List of target image paths
        feature_type: 'texture', 'color', or 'edge'

    Returns:
        Dictionary with matches and metadata
    """
    query_img = _load_image(query_image_path)

    query_features = _extract_query_features(query_img, pattern_boxes, feature_type)

    if not query_features:
        raise ValueError("Could not extract features from pattern boxes")

    matches = _match_against_targets(query_img, query_features, target_images, feature_type)
    matches = _sort_by_similarity(matches)

    return {
        'success': True,
        'n_query_patterns': len(query_features),
        'n_matches': len(matches),
        'matches': matches
    }


def _load_image(image_path):
    """Load image from path."""
    img = cv2.imread(image_path)
    if img is None:
        raise ValueError(f"Could not load image: {image_path}")
    return img


def _extract_query_features(query_img, pattern_boxes, feature_type):
    """Extract features from query pattern boxes."""
    query_features = []

    for box in pattern_boxes:
        roi = _extract_roi(query_img, box)
        if roi.size == 0:
            continue

        feature = _extract_feature(roi, feature_type)
        if feature is not None:
            query_features.append({
                'box': box,
                'feature': feature,
                'index': len(query_features)
            })

    return query_features


def _extract_roi(img, box):
    """Extract ROI from image."""
    x1, y1, x2, y2 = box
    return img[y1:y2, x1:x2]


def _extract_feature(roi, feature_type):
    """Extract feature from ROI."""
    return extract_pattern_feature(roi, feature_type)


def _match_against_targets(query_img, query_features, target_images, feature_type):
    """Match features against target images."""
    matches = []

    for target_path in target_images:
        target_img = cv2.imread(target_path)
        if target_img is None:
            continue

        target_matches = _match_to_target_image(
            query_img, query_features, target_img, feature_type
        )
        matches.extend(target_matches)

    return matches


def _match_to_target_image(query_img, query_features, target_img, feature_type):
    """Match features to a single target image."""
    matches = []

    for qf in query_features:
        query_roi = _extract_roi(query_img, qf['box'])
        target_match = _match_single_feature(
            query_roi, target_img, qf, feature_type
        )
        if target_match:
            matches.append(target_match)

    return matches


def _match_single_feature(query_roi, target_img, qf, feature_type):
    """Match a single feature against target image."""
    if feature_type in ['texture', 'edge']:
        return _match_texture_or_edge(query_roi, target_img, qf)
    elif feature_type == 'color':
        return _match_color(query_roi, target_img, qf)
    return None


def _match_texture_or_edge(query_roi, target_img, qf):
    """Match texture or edge features using template matching."""
    matches_loc = cv2.matchTemplate(
        target_img, query_roi, cv2.TM_CCOEFF_NORMED
    )
    min_val, max_val, min_loc, max_loc = cv2.minMaxLoc(matches_loc)

    if max_val > 0.6:
        h, w = query_roi.shape[:2]
        return {
            'query_box': qf['box'],
            'target_box': [max_loc[0], max_loc[1], max_loc[0] + w, max_loc[1] + h],
            'similarity': max_val,
            'target_image': target_img
        }
    return None


def _match_color(query_roi, target_img, qf):
    """Match color features using histogram comparison."""
    from modules.features import extract_pattern_feature

    target_hist = extract_pattern_feature(target_img, 'color')
    if target_hist is not None:
        similarity = cv2.compareHist(qf['feature'], target_hist, cv2.HISTCMP_CORREL)

        if similarity > 0.7:
            h, w = target_img.shape[:2]
            return {
                'query_box': qf['box'],
                'target_box': [w // 4, h // 4, 3 * w // 4, 3 * h // 4],
                'similarity': similarity,
                'target_image': target_img
            }
    return None


def _sort_by_similarity(matches):
    """Sort matches by similarity score."""
    return sorted(matches, key=lambda x: x['similarity'], reverse=True)
