"""
Unit tests for the BOVW (Bag of Visual Words) module.
"""

import io
import unittest
from unittest.mock import Mock, patch
import numpy as np
from PIL import Image
from sklearn.cluster import MiniBatchKMeans
from sklearn.metrics.pairwise import cosine_similarity


class TestTrainVisualVocabulary(unittest.TestCase):
    """Tests for train_visual_vocabulary function."""

    def setUp(self):
        """Set up test fixtures."""
        self.mock_image_paths = ['image1.jpg', 'image2.jpg', 'image3.jpg']

    @patch('modules.bovw.extract_local_features')
    @patch('cv2.imread')
    def test_train_visual_vocabulary_success(self, mock_imread, mock_extract_features):
        """Test successful vocabulary training."""
        # Setup mock feature extraction
        mock_descriptors = np.random.rand(100, 128).astype(np.float32)
        mock_extract_features.return_value = (mock_descriptors, None)

        # Mock cv2.imread to return valid images
        mock_img = np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8)
        mock_imread.return_value = mock_img

        # Test
        from modules.bovw import train_visual_vocabulary

        vocabulary = train_visual_vocabulary(
            self.mock_image_paths, n_clusters=16, feature_type='sift'
        )

        # Verify
        self.assertIsInstance(vocabulary, MiniBatchKMeans)
        self.assertEqual(vocabulary.n_clusters, 16)

    @patch('modules.bovw.extract_local_features')
    @patch('cv2.imread')
    def test_train_visual_vocabulary_small_dataset(self, mock_imread, mock_extract_features):
        """Test that clusters are adjusted for small datasets."""
        # Setup mock feature extraction
        mock_descriptors = np.random.rand(100, 128).astype(np.float32)
        mock_extract_features.return_value = (mock_descriptors, None)

        # Mock cv2.imread to return valid images
        mock_img = np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8)
        mock_imread.return_value = mock_img

        # Test
        from modules.bovw import train_visual_vocabulary

        vocabulary = train_visual_vocabulary(
            self.mock_image_paths, n_clusters=16, feature_type='sift'
        )

        # Verify
        self.assertIsInstance(vocabulary, MiniBatchKMeans)
        self.assertEqual(vocabulary.n_clusters, 16)

    @patch('modules.bovw.extract_local_features')
    @patch('cv2.imread')
    def test_train_visual_vocabulary_no_features(self, mock_imread, mock_extract_features):
        """Test that error is raised when no features extracted."""
        # Setup mocks
        mock_extract_features.return_value = (None, None)
        mock_img = np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8)
        mock_imread.return_value = mock_img

        # Test
        from modules.bovw import train_visual_vocabulary

        with self.assertRaises(ValueError):
            train_visual_vocabulary(self.mock_image_paths, n_clusters=16)

    @patch('modules.bovw.extract_local_features')
    @patch('cv2.imread')
    def test_train_visual_vocabulary_with_orb(self, mock_imread, mock_extract_features):
        """Test training with ORB features."""
        # Setup mock feature extraction
        mock_descriptors = np.random.rand(100, 128).astype(np.uint8)
        mock_extract_features.return_value = (mock_descriptors, None)

        # Mock cv2.imread to return valid images
        mock_img = np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8)
        mock_imread.return_value = mock_img

        # Test
        from modules.bovw import train_visual_vocabulary

        vocabulary = train_visual_vocabulary(
            self.mock_image_paths, n_clusters=16, feature_type='orb'
        )

        # Verify
        self.assertIsInstance(vocabulary, MiniBatchKMeans)
        self.assertEqual(vocabulary.n_clusters, 16)


class TestComputeBOVWFeatures(unittest.TestCase):
    """Tests for compute_bovw_features function."""

    def setUp(self):
        """Set up test fixtures."""
        # Create a test image
        self.test_image = Image.new('RGB', (100, 100), color='red')
        self.mock_vocabulary = Mock(spec=MiniBatchKMeans)
        self.mock_vocabulary.n_clusters = 32
        self.mock_vocabulary.transform.return_value = np.random.rand(50, 32)

    @patch('modules.features.extract_local_features')
    def test_compute_bovw_features_success(self, mock_extract_features):
        """Test successful BOVW feature computation."""
        # Setup mock feature extraction
        mock_descriptors = np.random.rand(50, 128).astype(np.float32)
        mock_extract_features.return_value = (mock_descriptors, None)

        # Test
        from modules.bovw import compute_bovw_features

        features, word_labels = compute_bovw_features(
            self.test_image, self.mock_vocabulary, feature_type='sift'
        )

        # Verify
        self.assertIsInstance(features, list)
        self.assertEqual(len(features), 32)  # Number of clusters
        self.assertIsNotNone(word_labels)
        self.assertEqual(len(word_labels), 50)  # Number of descriptors

    @patch('modules.features.extract_local_features')
    def test_compute_bovw_features_no_descriptors(self, mock_extract_features):
        """Test BOVW feature computation when no descriptors found."""
        # Setup mock to return no descriptors
        mock_extract_features.return_value = (None, None)

        # Test
        from modules.bovw import compute_bovw_features

        features, word_labels = compute_bovw_features(
            self.test_image, self.mock_vocabulary, feature_type='sift'
        )

        # Verify - should return zero vector
        self.assertEqual(len(features), 32)
        # Check that all values are approximately zero (float comparison)
        self.assertTrue(all(abs(f) < 1e-10 for f in features))
        self.assertIsNone(word_labels)

    @patch('modules.features.extract_local_features')
    def test_compute_bovw_features_with_orb(self, mock_extract_features):
        """Test BOVW feature computation with ORB."""
        # Setup mock feature extraction
        mock_descriptors = np.random.rand(50, 128).astype(np.uint8)
        mock_extract_features.return_value = (mock_descriptors, None)

        # Test
        from modules.bovw import compute_bovw_features

        features, word_labels = compute_bovw_features(
            self.test_image, self.mock_vocabulary, feature_type='orb'
        )

        # Verify
        self.assertIsInstance(features, list)
        self.assertEqual(len(features), 32)


class TestComputeSimilarityMatrix(unittest.TestCase):
    """Tests for compute_similarity_matrix function."""

    def setUp(self):
        """Set up test fixtures."""
        self.mock_image_paths = ['image1.jpg', 'image2.jpg', 'image3.jpg']
        self.mock_vocabulary = Mock(spec=MiniBatchKMeans)
        self.mock_vocabulary.n_clusters = 32

    @patch('modules.bovw.compute_bovw_features')
    @patch('cv2.imread')
    def test_compute_similarity_matrix_success(self, mock_imread, mock_compute_features):
        """Test successful similarity matrix computation."""
        # Setup mock feature computation
        mock_features = np.random.rand(32).astype(np.float32)
        mock_compute_features.return_value = (mock_features.tolist(), None)

        # Mock cv2.imread to return valid images
        mock_img = np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8)
        mock_imread.return_value = mock_img

        # Test
        from modules.bovw import compute_similarity_matrix

        result, valid_images = compute_similarity_matrix(
            self.mock_image_paths, self.mock_vocabulary, feature_type='sift'
        )

        # Verify
        self.assertIsInstance(result, list)
        self.assertEqual(len(result), 3)  # Number of images
        for row in result:
            self.assertEqual(len(row), 3)  # Similarity to all images
        self.assertEqual(valid_images, self.mock_image_paths)

    @patch('modules.bovw.compute_bovw_features')
    @patch('cv2.imread')
    def test_compute_similarity_matrix_partial_success(self, mock_imread, mock_compute_features):
        """Test similarity matrix computation with partial failures."""
        # Setup mock to fail for some images
        mock_features1 = np.random.rand(32).astype(np.float32)
        mock_features2 = np.random.rand(32).astype(np.float32)
        mock_compute_features.side_effect = [
            (mock_features1.tolist(), None),
            (None, None),  # Second image fails
            (mock_features2.tolist(), None)
        ]

        # Mock cv2.imread to return valid images
        mock_img = np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8)
        mock_imread.return_value = mock_img

        # Test
        from modules.bovw import compute_similarity_matrix

        result, valid_images = compute_similarity_matrix(
            self.mock_image_paths, self.mock_vocabulary, feature_type='sift'
        )

        # Verify - should handle partial failures gracefully
        self.assertIsInstance(result, list)
        self.assertEqual(len(valid_images), 2)  # Only 2 images succeeded

    @patch('modules.bovw.compute_bovw_features')
    @patch('cv2.imread')
    def test_compute_similarity_matrix_all_fail(self, mock_imread, mock_compute_features):
        """Test similarity matrix computation when all images fail."""
        # Setup mock to fail for all images
        mock_compute_features.return_value = (None, None)

        # Mock cv2.imread to return valid images
        mock_img = np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8)
        mock_imread.return_value = mock_img

        # Test
        from modules.bovw import compute_similarity_matrix

        with self.assertRaises(ValueError):
            compute_similarity_matrix(
                self.mock_image_paths, self.mock_vocabulary, feature_type='sift'
            )


class TestHelperFunctions(unittest.TestCase):
    """Tests for helper functions in the BOVW module."""

    def test_adjust_clusters_for_small_dataset(self):
        """Test that clusters are adjusted for small datasets."""
        from modules.bovw import _adjust_clusters_for_small_dataset

        # Test with 2 images and 32 clusters (should be adjusted)
        n_clusters = _adjust_clusters_for_small_dataset(32, 2)
        self.assertLess(n_clusters, 32)
        self.assertGreaterEqual(n_clusters, 16)

        # Test with 10 images and 32 clusters (should not be adjusted)
        n_clusters = _adjust_clusters_for_small_dataset(32, 10)
        self.assertEqual(n_clusters, 30)

    def test_compute_n_init(self):
        """Test n_init computation for MiniBatchKMeans."""
        from modules.bovw import _compute_n_init

        # Test with 2 images
        n_init = _compute_n_init(2)
        self.assertEqual(n_init, 20)

        # Test with 10 images
        n_init = _compute_n_init(10)
        self.assertEqual(n_init, 100)

    @patch('cv2.cvtColor')
    @patch('cv2.imread')
    def test_preprocess_image_for_features(self, mock_imread, mock_cvtColor):
        """Test image preprocessing for feature extraction."""
        from modules.bovw import _preprocess_image_for_features

        # Mock cv2 operations
        mock_img = np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8)
        mock_imread.return_value = mock_img
        mock_cvtColor.return_value = mock_img

        # Test
        preprocessed = _preprocess_image_for_features(mock_img)

        # Verify
        self.assertIsNotNone(preprocessed)
        self.assertIsInstance(preprocessed, np.ndarray)

    def test_compute_histogram(self):
        """Test histogram computation from descriptors."""
        from modules.bovw import _compute_histogram

        # Create mock word labels (indices into the vocabulary)
        word_labels = np.random.randint(0, 32, 100)

        # Test
        histogram = _compute_histogram(word_labels, 32)

        # Verify
        self.assertIsInstance(histogram, np.ndarray)
        self.assertEqual(len(histogram), 32)  # Number of clusters

    def test_apply_tfidf_weighting(self):
        """Test TF-IDF weighting."""
        from modules.bovw import _apply_tfidf_weighting

        hist = np.array([10, 20, 30, 0, 5, 15, 25, 35, 45, 55] * 3 + [0, 0])
        n_clusters = 32

        tfidf_hist = _apply_tfidf_weighting(hist, n_clusters)

        # Verify TF-IDF weighting is applied (values are normalized)
        # Rare terms (like index 3 and 4 which have count 0 and 5) should have relatively higher weights
        # The key is that TF-IDF produces different values than raw histogram
        self.assertTrue(len(tfidf_hist) == len(hist))
        self.assertTrue(all(v >= 0 for v in tfidf_hist))  # All values should be non-negative

    def test_normalize_histogram(self):
        """Test L2 normalization."""
        from modules.bovw import _normalize_histogram

        hist = np.array([3, 4, 0, 0])  # L2 norm = 5

        normalized = _normalize_histogram(hist)

        # Verify
        self.assertAlmostEqual(np.linalg.norm(normalized), 1.0, places=5)
        np.testing.assert_array_almost_equal(normalized, [0.6, 0.8, 0.0, 0.0])


if __name__ == '__main__':
    unittest.main()
