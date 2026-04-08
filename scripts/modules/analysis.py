"""
Analysis module for various ML tasks.
"""

import cv2
import io
import torch
import numpy as np
from PIL import Image
from transforms import PILToTensor

from modules.models import registry, device


def analyze_file(file):
    """
    Analyze image for object detection.

    Args:
        file: File object with image data

    Returns:
        List of predictions with score, box, and label
    """
    pil_image = _load_image_from_file(file)
    img_tensor = _convert_to_tensor(pil_image)

    with torch.no_grad():
        prediction = registry.detection_model([img_tensor.to(device)])

    return _parse_detection_predictions(prediction)


def _load_image_from_file(file):
    """Load PIL Image from file object."""
    request_content = file.read()
    return Image.open(io.BytesIO(request_content))


def _convert_to_tensor(pil_image):
    """Convert PIL Image to tensor."""
    from transforms import PILToTensor

    img, _ = PILToTensor()(pil_image)
    return torch.stack([img])


def _parse_detection_predictions(prediction):
    """Parse model predictions into result format."""
    result = []
    labels = registry.label2id

    for element in range(len(prediction[0]["boxes"])):
        boxes = _parse_box(prediction[0]["boxes"][element])
        score = _parse_score(prediction[0]["scores"][element])
        label = _parse_label(prediction[0]['labels'][element], labels)

        if score > 0.1:
            result.append({
                'score': score,
                'box': boxes,
                'label': label
            })

    return result


def _parse_box(box_tensor):
    """Parse box tensor to list."""
    return box_tensor.cpu().numpy().tolist()


def _parse_score(score_tensor):
    """Parse score tensor to float."""
    return np.round(score_tensor.cpu().numpy(), decimals=4)


def _parse_label(label_tensor, labels):
    """Parse label tensor to string."""
    return labels[label_tensor.cpu().item()]


def analyze_arrow(file):
    """
    Analyze arrow orientation.

    Args:
        file: File object with image data

    Returns:
        Arrow orientation prediction [cos, sin]
    """
    pil_image = _load_image_from_file(file)
    img_tensor = _convert_to_tensor(pil_image)

    with torch.no_grad():
        registry.arrow_model.eval()
        prediction = registry.arrow_model(img_tensor.to(device))

    return prediction


def analyze_skeleton(file):
    """
    Classify skeleton orientation.

    Args:
        file: File object with image data

    Returns:
        Skeleton classification label
    """
    pil_image = _load_image_from_file(file)
    img_tensor = _convert_to_tensor(pil_image)

    with torch.no_grad():
        registry.skeleton_model.eval()
        prediction = registry.skeleton_model(img_tensor.to(device))
        _, prediction = torch.max(prediction, 1)

    return registry.skeleton_labels[prediction]


def extract_object_features(file, vocabulary=None):
    """
    Extract features from an object image.

    Args:
        file: File object with image data
        vocabulary: Optional BOVW vocabulary

    Returns:
        Feature vector
    """
    request_content = file.read()
    img = Image.open(io.BytesIO(request_content))
    img_array = np.array(img)

    if vocabulary is not None:
        try:
            enhanced = _preprocess_for_bovw(img_array)
            bovw_features, _ = _compute_bovw_with_preprocessing(
                enhanced, vocabulary
            )
            return bovw_features
        except Exception as e:
            print(f"BOVW extraction failed: {e}, falling back to backbone")

    return _extract_backbone_features(request_content)


def _preprocess_for_bovw(img_array):
    """Preprocess image for BOVW extraction."""
    if len(img_array.shape) == 3:
        lab = cv2.cvtColor(img_array, cv2.COLOR_BGR2LAB)
        l_channel = lab[:, :, 0]
        clahe = cv2.createCLAHE(clipLimit=3.0, tileGridSize=(8, 8))
        return clahe.apply(l_channel)
    return img_array


def _compute_bovw_with_preprocessing(enhanced, vocabulary):
    """Compute BOVW features from preprocessed image."""
    from modules.bovw import compute_bovw_features
    return compute_bovw_features(enhanced, vocabulary, feature_type='sift')


def _extract_backbone_features(request_content):
    """Extract backbone features as fallback."""

    pil_image = Image.open(io.BytesIO(request_content))
    img_tensor, _ = PILToTensor()(pil_image)
    img_tensor = torch.stack([img_tensor]).to(device)

    with torch.no_grad():
        registry.detection_model.backbone.eval()
        return registry.detection_model.backbone(img_tensor.to(device))
