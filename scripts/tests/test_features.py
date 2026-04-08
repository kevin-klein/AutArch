"""
Unit tests for the features module.
"""

import unittest
from unittest.mock import Mock, patch, MagicMock
import numpy as np
import cv2


class TestExtractLocalFeatures(unittest.TestCase):
    """Tests for extract_local_features function."""

    def setUp(self):
        """Set up test fixtures."""
        # Create a simple test image (100x100 gray image)
        self.test_image = np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8)

    @patch('cv2.SIFT_create')
    def test_extract_sift_features_success(self, mock_sift_create):
        """Test SIFT feature extraction succeeds."""
        # Setup mock
        mock_sift = Mock()
        mock_sift_create.return_value = mock_sift

        # Create mock keypoints with responses
        mock_keypoints = [Mock() for _ in range(10)]
        for i, kp in enumerate(mock_keypoints):
            kp.response = 100 - i * 5  # Varying responses

        mock_descriptors = np.random.rand(10, 128).astype(np.float32)
        mock_sift.detectAndCompute.return_value = (mock_keypoints, mock_descriptors)

        # Test
        from modules.features import extract_local_features

        descriptors, keypoints = extract_local_features(self.test_image, 'sift')

        # Verify
        self.assertIsNotNone(descriptors)
        self.assertIsNotNone(keypoints)
        self.assertGreater(len(descriptors), 0)
        self.assertGreater(len(keypoints), 0)
        mock_sift.detectAndCompute.assert_called_once()

    @patch('cv2.SIFT_create')
    def test_extract_sift_features_no_descriptors(self, mock_sift_create):
        """Test SIFT feature extraction when no descriptors found."""
        # Setup mock
        mock_sift = Mock()
        mock_sift_create.return_value = mock_sift
        mock_sift.detectAndCompute.return_value = (None, None)

        # Test
        from modules.features import extract_local_features

        descriptors, keypoints = extract_local_features(self.test_image, 'sift')

        # Verify
        self.assertIsNone(descriptors)
        self.assertIsNone(keypoints)

    @patch('cv2.ORB_create')
    def test_extract_orb_features_success(self, mock_orb_create):
        """Test ORB feature extraction succeeds."""
        # Setup mock
        mock_orb = Mock()
        mock_orb_create.return_value = mock_orb

        mock_keypoints = [Mock() for _ in range(10)]
        mock_descriptors = np.random.rand(10, 128).astype(np.uint8)
        mock_orb.detectAndCompute.return_value = (mock_keypoints, mock_descriptors)

        # Test
        from modules.features import extract_local_features

        descriptors, keypoints = extract_local_features(self.test_image, 'orb')

        # Verify
        self.assertIsNotNone(descriptors)
        self.assertIsNotNone(keypoints)
        mock_orb.detectAndCompute.assert_called_once()

    @patch('cv2.ORB_create')
    def test_extract_orb_features_no_descriptors(self, mock_orb_create):
        """Test ORB feature extraction when no descriptors found."""
        # Setup mock
        mock_orb = Mock()
        mock_orb_create.return_value = mock_orb
        mock_orb.detectAndCompute.return_value = (None, None)

        # Test
        from modules.features import extract_local_features

        descriptors, keypoints = extract_local_features(self.test_image, 'orb')

        # Verify
        self.assertIsNone(descriptors)
        self.assertIsNone(keypoints)

    def test_extract_local_features_invalid_type(self):
        """Test that invalid feature type raises ValueError."""
        # Test
        from modules.features import extract_local_features

        with self.assertRaises(ValueError):
            extract_local_features(self.test_image, 'invalid_type')


class TestExtractPatternFeature(unittest.TestCase):
    """Tests for extract_pattern_feature function."""

    def setUp(self):
        """Set up test fixtures."""
        self.test_image = np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8)

    @patch('modules.features._extract_texture_feature')
    def test_extract_texture_feature(self, mock_texture):
        """Test texture feature extraction."""
        mock_texture.return_value = [0.1, 0.2, 0.3]

        from modules.features import extract_pattern_feature

        result = extract_pattern_feature(self.test_image, 'texture')

        self.assertEqual(result, [0.1, 0.2, 0.3])
        mock_texture.assert_called_once_with(self.test_image)

    @patch('modules.features._extract_color_feature')
    def test_extract_color_feature(self, mock_color):
        """Test color feature extraction."""
        mock_color.return_value = np.array([0.1, 0.2, 0.3])

        from modules.features import extract_pattern_feature

        result = extract_pattern_feature(self.test_image, 'color')

        self.assertIsNotNone(result)
        mock_color.assert_called_once_with(self.test_image)

    @patch('modules.features._extract_edge_feature')
    def test_extract_edge_feature(self, mock_edge):
        """Test edge feature extraction."""
        mock_edge.return_value = [0.1, 0.2, 0.3]

        from modules.features import extract_pattern_feature

        result = extract_pattern_feature(self.test_image, 'edge')

        self.assertEqual(result, [0.1, 0.2, 0.3])
        mock_edge.assert_called_once_with(self.test_image)

    def test_extract_pattern_feature_invalid_type(self):
        """Test that invalid feature type returns None."""
        from modules.features import extract_pattern_feature

        result = extract_pattern_feature(self.test_image, 'invalid')
        self.assertIsNone(result)


class TestFeatureFiltering(unittest.TestCase):
    """Tests for feature filtering functions."""

    def test_filter_sift_features_with_quality(self):
        """Test SIFT feature filtering with quality threshold."""
        from modules.features import _filter_sift_features

        # Create mock keypoints with varying responses
        mock_keypoints = []
        responses = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
        for resp in responses:
            kp = Mock()
            kp.response = resp
            mock_keypoints.append(kp)

        descriptors = np.random.rand(10, 128).astype(np.float32)

        filtered_descriptors, filtered_keypoints = _filter_sift_features(
            descriptors, mock_keypoints
        )

        # Should filter out lower 25th percentile (responses < 35)
        self.assertLess(len(filtered_descriptors), len(descriptors))
        self.assertLess(len(filtered_keypoints), len(mock_keypoints))


if __name__ == '__main__':
    unittest.main()
