"""
SAM (Segment Anything Model) segmentation module.
"""

import cv2
import json
import numpy as np
import torch
from PIL import Image
import io

from modules.models import registry, device


def segment_image(upload_file, points_json):
    """
    Segment image using SAM based on user-provided points.

    Args:
        upload_file: File object with image data
        points_json: JSON string of coordinates

    Returns:
        Dictionary with score and contour
    """
    pil_image = _load_image_from_file(upload_file)
    open_cv_image = np.array(pil_image)

    _set_sam_image(open_cv_image)
    points = _parse_points(points_json)
    input_point, input_label = _prepare_points(points)

    masks, scores, _ = _run_segmentation(input_point, input_label)
    best_mask, best_score = _select_best_mask(masks, scores)

    contour = _extract_contour(best_mask)

    return {
        'predictions': {
            'score': best_score.item(),
            'contour': contour
        }
    }


def _load_image_from_file(upload_file):
    """Load PIL Image from file object."""
    request_content = upload_file.file.read()
    return Image.open(io.BytesIO(request_content))


def _set_sam_image(open_cv_image):
    """Set image for SAM predictor."""
    registry.sam_predictor.set_image(open_cv_image)


def _run_segmentation(input_point, input_label):
    """Run SAM segmentation."""
    return registry.sam_predictor.predict(
        point_coords=input_point,
        point_labels=input_label,
        multimask_output=False,
    )


def _parse_points(points_json):
    """Parse points from JSON string."""
    return json.loads(points_json)


def _prepare_points(points):
    """Prepare points for SAM prediction."""
    input_point = np.array(points)
    input_label = np.array([1] * len(points))
    return input_point, input_label


def _run_segmentation(input_point, input_label):
    """Run SAM segmentation."""
    return registry.sam_predictor.predict(
        point_coords=input_point,
        point_labels=input_label,
        multimask_output=False,
    )


def _select_best_mask(masks, scores):
    """Select the best mask based on score."""
    mask_sizes = masks.sum(axis=(1, 2))
    largest_idx = mask_sizes.argmax()
    return masks[largest_idx], scores[largest_idx]


def _extract_contour(mask):
    """Extract contour from mask."""
    h, w = mask.shape[-2:]
    mask = mask.reshape(h, w)
    mask = mask.astype(dtype='uint8')
    mask *= 255

    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)

    return [
        contour[:, 0, :].astype(int).tolist()
        for contour in contours
    ]


def save_masks_as_images(masks, output_dir="masks_out"):
    """
    Save all boolean masks to image files.

    Args:
        masks: np.ndarray or torch.Tensor of shape (N, H, W), dtype=bool
        output_dir: folder to save the images
    """
    import os

    if isinstance(masks, torch.Tensor):
        masks = masks.cpu().numpy()

    os.makedirs(output_dir, exist_ok=True)

    for i, mask in enumerate(masks):
        img = (mask.astype(np.uint8)) * 255
        im = Image.fromarray(img, mode="L")
        im.save(os.path.join(output_dir, f"mask_{i:03d}.png"))

    print(f"Saved {len(masks)} masks to '{output_dir}/'")
