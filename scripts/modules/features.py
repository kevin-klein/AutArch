"""
Feature extraction module for SIFT and ORB features.
"""

import cv2
import numpy as np


def extract_local_features(image_array, feature_type='sift'):
    """
    Extract local features from an image with quality filtering.

    Args:
        image_array: numpy array of the image
        feature_type: 'sift' or 'orb'

    Returns:
        Tuple of (descriptors, keypoints) or (None, None) if extraction fails
    """
    if feature_type == 'sift':
        return _extract_sift_features(image_array)
    elif feature_type == 'orb':
        return _extract_orb_features(image_array)
    else:
        raise ValueError(f"Unknown feature type: {feature_type}")


def _extract_sift_features(image_array):
    """Extract SIFT features with quality filtering."""
    sift = cv2.SIFT_create(
        nfeatures=0,
        nOctaveLayers=3,
        contrastThreshold=0.02,
        edgeThreshold=10,
        sigma=1.6
    )

    keypoints, descriptors = sift.detectAndCompute(image_array, None)

    if descriptors is not None and len(keypoints) > 0:
        return _filter_sift_features(descriptors, keypoints)
    return None, None


def _filter_sift_features(descriptors, keypoints):
    """Filter SIFT features based on quality."""
    responses = np.array([kp.response for kp in keypoints])
    threshold = np.percentile(responses, 25)
    quality_mask = responses > threshold

    if np.any(quality_mask):
        descriptors = descriptors[quality_mask]
        keypoints = [kp for kp, mask in zip(keypoints, quality_mask) if mask]
    return descriptors, keypoints


def _extract_orb_features(image_array):
    """Extract ORB features."""
    orb = cv2.ORB_create(nfeatures=1000, scoreType=cv2.ORB_FAST_SCORE)
    keypoints, descriptors = orb.detectAndCompute(image_array, None)

    if descriptors is not None and len(keypoints) > 0:
        return descriptors, keypoints
    return None, None


def extract_pattern_feature(image_array, feature_type='texture'):
    """
    Extract features from a pattern region.

    Args:
        image_array: numpy array of the pattern region
        feature_type: 'texture', 'color', or 'edge'

    Returns:
        Feature vector or None if extraction fails
    """
    if feature_type == 'texture':
        return _extract_texture_feature(image_array)
    elif feature_type == 'color':
        return _extract_color_feature(image_array)
    elif feature_type == 'edge':
        return _extract_edge_feature(image_array)
    return None


def _extract_texture_feature(image_array):
    """Extract texture features using SIFT."""
    sift = cv2.SIFT_create()
    keypoints, descriptors = sift.detectAndCompute(image_array, None)

    if descriptors is not None and len(descriptors) > 0:
        return descriptors.mean(axis=0).tolist()
    return None


def _extract_color_feature(image_array):
    """Extract color features using LAB histogram."""
    lab = cv2.cvtColor(image_array, cv2.COLOR_BGR2LAB)

    hist_l = cv2.calcHist([lab], [0], None, [32], [0, 256])
    hist_a = cv2.calcHist([lab], [1], None, [32], [-128, 128])
    hist_b = cv2.calcHist([lab], [2], None, [32], [-128, 128])

    hist = np.concatenate([hist_l, hist_a, hist_b])
    return hist.flatten()


def _extract_edge_feature(image_array):
    """Extract edge features using Canny and orientation histogram."""
    gray = cv2.cvtColor(image_array, cv2.COLOR_BGR2GRAY)
    edges = cv2.Canny(gray, 50, 150)

    orientations = np.arctan2(*np.gradient(edges)[::-1])
    hist, _ = np.histogram(orientations, bins=18, range=(-np.pi, np.pi))
    return hist.tolist()
