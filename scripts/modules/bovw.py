"""
Bag of Visual Words (BOVW) training and computation module.
"""

import cv2
import numpy as np
from sklearn.cluster import MiniBatchKMeans
from sklearn.metrics.pairwise import cosine_similarity
from modules.features import extract_local_features


def train_visual_vocabulary(image_paths, n_clusters=32, feature_type='sift'):
    """
    Train a Bag of Visual Words vocabulary.

    Args:
        image_paths: List of image paths
        n_clusters: Number of visual words
        feature_type: 'sift' or 'orb'

    Returns:
        Trained MiniBatchKMeans model
    """
    print("Extracting features for vocabulary training...")
    n_images = len(image_paths)

    max_clusters = _adjust_clusters_for_small_dataset(n_clusters, n_images)
    if max_clusters != n_clusters:
        print(f"Adjusted clusters from {n_clusters} to {max_clusters}")

    all_features, feature_counts = _extract_features_from_images(image_paths, feature_type)

    if len(all_features) == 0:
        raise ValueError("No features extracted from images")

    all_features = np.vstack(all_features)
    print(f"Total features extracted: {all_features.shape[0]}")
    print(f"Average features per image: {np.mean(feature_counts):.1f}")

    n_init = _compute_n_init(n_images)
    vocabulary = _train_kmeans(all_features, max_clusters, n_init)

    print(f"Visual vocabulary trained! Shape: {vocabulary.cluster_centers_.shape}")
    return vocabulary


def _adjust_clusters_for_small_dataset(n_clusters, n_images):
    """Adjust number of clusters for small datasets."""
    max_clusters = max(16, min(n_clusters, n_images * 3))
    return max_clusters


def _compute_n_init(n_images):
    """Compute appropriate n_init value."""
    return max(20, min(100, n_images * 10))


def _extract_features_from_images(image_paths, feature_type):
    """Extract features from all images."""

    all_features = []
    feature_counts = []

    for img_path in image_paths:
        img = cv2.imread(img_path)
        if img is None:
            print(f"Warning: Could not read {img_path}")
            continue

        enhanced = _preprocess_image_for_features(img)
        descriptors, _ = extract_local_features(enhanced, feature_type)

        if descriptors is not None and len(descriptors) >= 5:
            all_features.append(descriptors)
            feature_counts.append(len(descriptors))

    return all_features, feature_counts


def _preprocess_image_for_features(img):
    """Preprocess image for feature extraction."""
    lab = cv2.cvtColor(img, cv2.COLOR_BGR2LAB)
    l_channel = lab[:, :, 0]

    clahe = cv2.createCLAHE(clipLimit=3.0, tileGridSize=(8, 8))
    enhanced = clahe.apply(l_channel)

    return enhanced


def _train_kmeans(features, n_clusters, n_init):
    """Train K-Means clustering."""
    kmeans = MiniBatchKMeans(
        n_clusters=n_clusters,
        random_state=42,
        n_init=n_init,
        batch_size=min(32, features.shape[0])
    )
    kmeans.fit(features)
    return kmeans


def compute_bovw_features(image_array, vocabulary, feature_type='sift'):
    """
    Compute Bag of Visual Words features for an image.

    Args:
        image_array: numpy array of the image
        vocabulary: Trained MiniBatchKMeans model
        feature_type: 'sift' or 'orb'

    Returns:
        Tuple of (TF-IDF histogram as list, word labels)
    """
    from modules.features import extract_local_features

    descriptors, _ = extract_local_features(image_array, feature_type)

    if descriptors is None or len(descriptors) == 0:
        return np.zeros(vocabulary.n_clusters), None

    word_labels = _assign_visual_words(descriptors, vocabulary)
    hist = _compute_histogram(word_labels, vocabulary.n_clusters)
    tfidf_hist = _apply_tfidf_weighting(hist, vocabulary.n_clusters)
    tfidf_hist = _normalize_histogram(tfidf_hist)

    return tfidf_hist.tolist(), word_labels


def _assign_visual_words(descriptors, vocabulary):
    """Assign each feature to nearest visual word."""
    distances = vocabulary.transform(descriptors)
    return distances.argmax(axis=1)


def _compute_histogram(word_labels, n_clusters):
    """Compute histogram of visual word occurrences."""
    hist, _ = np.histogram(word_labels, bins=n_clusters, range=(0, n_clusters))
    return hist


def _apply_tfidf_weighting(hist, n_clusters):
    """Apply TF-IDF weighting."""
    idf = np.log((n_clusters + 1) / (hist + 1)) + 1
    return hist * idf


def _normalize_histogram(hist):
    """L2 normalize histogram."""
    norm = np.linalg.norm(hist)
    if norm > 0:
        return hist / norm
    return hist


def compute_similarity_matrix(image_paths, vocabulary, feature_type='sift'):
    """
    Compute similarity matrix for a set of images.

    Args:
        image_paths: List of image paths
        vocabulary: Trained MiniBatchKMeans model
        feature_type: 'sift' or 'orb'

    Returns:
        Similarity matrix as 2D list
    """
    all_features = []
    valid_images = []

    for img_path in image_paths:
        img = cv2.imread(img_path)
        if img is None:
            continue

        enhanced = _preprocess_image_for_features(img)
        features, _ = compute_bovw_features(enhanced, vocabulary, feature_type)

        if features is not None and len(features) > 0:
            all_features.append(features)
            valid_images.append(img_path)

    if len(all_features) == 0:
        raise ValueError("No valid features extracted")

    all_features = np.array(all_features)

    cosine_sim = cosine_similarity(all_features)
    correlation_sim = _compute_correlation_similarity(all_features)

    blended_sim = 0.8 * cosine_sim + 0.2 * correlation_sim
    return blended_sim.tolist(), valid_images


def _compute_correlation_similarity(features):
    """Compute correlation-based similarity."""
    correlation_sim = np.corrcoef(features)
    return np.nan_to_num(correlation_sim, nan=0.0)
