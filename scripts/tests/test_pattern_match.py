"""
Unit tests for the pattern matching module.
"""

import unittest
from unittest.mock import Mock, patch, MagicMock
import numpy as np
import cv2


class TestMatchPatternParts(unittest.TestCase):
    """Tests for match_pattern_parts function."""

    def setUp(self):
        """Set up test fixtures."""
        self.test_image = np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8)
        self.pattern_boxes = [[10, 10, 30, 30], [50, 50, 70, 70]]
        self.target_images = ['target1.jpg', 'target2.jpg']

    @patch('modules.pattern_match._extract_query_features')
    @patch('modules.pattern_match._match_against_targets')
    @patch('modules.pattern_match._load_image')
    def test_match_pattern_parts_success(
        self, mock_load_image, mock_match_targets, mock_extract_query
    ):
        """Test successful pattern matching."""
        # Setup mocks
        mock_load_image.return_value = self.test_image

        mock_query_features = [
            {'box': [10, 10, 30, 30], 'feature': np.random.rand(128), 'index': 0},
            {'box': [50, 50, 70, 70], 'feature': np.random.rand(128), 'index': 1}
        ]
        mock_extract_query.return_value = mock_query_features

        mock_matches = [
            {
                'query_box': [10, 10, 30, 30],
                'target_box': [15, 15, 35, 35],
                'similarity': 0.85,
                'target_image': self.test_image
            }
        ]
        mock_match_targets.return_value = mock_matches

        # Test
        from modules.pattern_match import match_pattern_parts

        result = match_pattern_parts(
            'query.jpg', self.pattern_boxes, self.target_images, 'texture'
        )

        # Verify
        self.assertTrue(result['success'])
        self.assertEqual(result['n_query_patterns'], 2)
        self.assertEqual(result['n_matches'], 1)
        self.assertIsInstance(result['matches'], list)

    @patch('modules.pattern_match._extract_query_features')
    def test_match_pattern_parts_no_features(self, mock_extract_query):
        """Test pattern matching when no features extracted."""
        # Setup mock to return no features
        mock_extract_query.return_value = []

        # Test
        from modules.pattern_match import match_pattern_parts

        with self.assertRaises(ValueError):
            match_pattern_parts(
                'query.jpg', self.pattern_boxes, self.target_images, 'texture'
            )


class TestLoadImage(unittest.TestCase):
    """Tests for _load_image function."""

    def test_load_image_success(self):
        """Test loading image successfully."""
        # Create test image
        test_image = np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8)

        with patch('cv2.imread', return_value=test_image):
            from modules.pattern_match import _load_image

            result = _load_image('test.jpg')

            # Verify
            self.assertIsNotNone(result)
            self.assertEqual(result.shape, (100, 100, 3))

    def test_load_image_failure(self):
        """Test loading image fails."""
        with patch('cv2.imread', return_value=None):
            from modules.pattern_match import _load_image

            with self.assertRaises(ValueError):
                _load_image('nonexistent.jpg')


class TestExtractQueryFeatures(unittest.TestCase):
    """Tests for _extract_query_features function."""

    def setUp(self):
        """Set up test fixtures."""
        self.test_image = np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8)
        self.pattern_boxes = [[10, 10, 30, 30], [50, 50, 70, 70]]

    @patch('modules.pattern_match._extract_feature')
    @patch('modules.pattern_match._extract_roi')
    def test_extract_query_features_success(self, mock_extract_roi, mock_extract_feature):
        """Test extracting features from query pattern boxes."""
        # Setup mocks
        mock_roi = np.random.randint(0, 255, (20, 20, 3), dtype=np.uint8)
        mock_extract_roi.return_value = mock_roi

        mock_feature = np.random.rand(128)
        mock_extract_feature.return_value = mock_feature

        # Test
        from modules.pattern_match import _extract_query_features

        features = _extract_query_features(self.test_image, self.pattern_boxes, 'texture')

        # Verify
        self.assertEqual(len(features), 2)
        self.assertIn('box', features[0])
        self.assertIn('feature', features[0])
        self.assertIn('index', features[0])

    @patch('modules.pattern_match._extract_feature')
    @patch('modules.pattern_match._extract_roi')
    def test_extract_query_features_empty_roi(self, mock_extract_roi, mock_extract_feature):
        """Test when ROI is empty."""
        # Setup mock to return empty ROI
        mock_extract_roi.return_value = np.array([])

        # Test
        from modules.pattern_match import _extract_query_features

        features = _extract_query_features(self.test_image, self.pattern_boxes, 'texture')

        # Verify - should skip empty ROIs
        self.assertEqual(len(features), 0)

    @patch('modules.pattern_match._extract_feature')
    @patch('modules.pattern_match._extract_roi')
    def test_extract_query_features_none_feature(self, mock_extract_roi, mock_extract_feature):
        """Test when feature extraction returns None."""
        # Setup mocks
        mock_roi = np.random.randint(0, 255, (20, 20, 3), dtype=np.uint8)
        mock_extract_roi.return_value = mock_roi
        mock_extract_feature.return_value = None

        # Test
        from modules.pattern_match import _extract_query_features

        features = _extract_query_features(self.test_image, self.pattern_boxes, 'texture')

        # Verify - should skip None features
        self.assertEqual(len(features), 0)


class TestExtractROI(unittest.TestCase):
    """Tests for _extract_roi function."""

    def test_extract_roi(self):
        """Test extracting ROI from image."""
        test_image = np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8)
        box = [10, 10, 30, 30]

        from modules.pattern_match import _extract_roi

        roi = _extract_roi(test_image, box)

        # Verify
        self.assertEqual(roi.shape, (20, 20, 3))


class TestExtractFeature(unittest.TestCase):
    """Tests for _extract_feature function."""

    def setUp(self):
        """Set up test fixtures."""
        self.test_roi = np.random.randint(0, 255, (20, 20, 3), dtype=np.uint8)

    @patch('modules.pattern_match.extract_pattern_feature')
    def test_extract_feature_texture(self, mock_extract_pattern):
        """Test extracting texture feature."""
        mock_extract_pattern.return_value = np.random.rand(128)

        from modules.pattern_match import _extract_feature

        feature = _extract_feature(self.test_roi, 'texture')

        # Verify
        self.assertIsNotNone(feature)
        mock_extract_pattern.assert_called_once_with(self.test_roi, 'texture')

    @patch('modules.pattern_match.extract_pattern_feature')
    def test_extract_feature_color(self, mock_extract_pattern):
        """Test extracting color feature."""
        mock_extract_pattern.return_value = np.random.rand(96)

        from modules.pattern_match import _extract_feature

        feature = _extract_feature(self.test_roi, 'color')

        # Verify
        self.assertIsNotNone(feature)
        mock_extract_pattern.assert_called_once_with(self.test_roi, 'color')

    @patch('modules.pattern_match.extract_pattern_feature')
    def test_extract_feature_edge(self, mock_extract_pattern):
        """Test extracting edge feature."""
        mock_extract_pattern.return_value = np.random.rand(18)

        from modules.pattern_match import _extract_feature

        feature = _extract_feature(self.test_roi, 'edge')

        # Verify
        self.assertIsNotNone(feature)
        mock_extract_pattern.assert_called_once_with(self.test_roi, 'edge')


class TestMatchAgainstTargets(unittest.TestCase):
    """Tests for _match_against_targets function."""

    def setUp(self):
        """Set up test fixtures."""
        self.test_image = np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8)
        self.mock_query_features = [
            {'box': [10, 10, 30, 30], 'feature': np.random.rand(128), 'index': 0}
        ]
        self.target_images = ['target1.jpg', 'target2.jpg']

    @patch('modules.pattern_match._match_to_target_image')
    @patch('cv2.imread')
    def test_match_against_targets_success(self, mock_imread, mock_match_to_target):
        """Test matching against multiple target images."""
        # Setup mock images
        mock_img = np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8)
        mock_imread.return_value = mock_img

        # Setup mock matches
        mock_match_to_target.return_value = [
            {
                'query_box': [10, 10, 30, 30],
                'target_box': [15, 15, 35, 35],
                'similarity': 0.85,
                'target_image': mock_img
            }
        ]

        # Test
        from modules.pattern_match import _match_against_targets

        matches = _match_against_targets(
            self.test_image, self.mock_query_features, self.target_images, 'texture'
        )

        # Verify
        self.assertEqual(len(matches), 2)  # 2 targets
        mock_imread.assert_called()

    @patch('modules.pattern_match._match_to_target_image')
    @patch('cv2.imread')
    def test_match_against_targets_partial_failure(
        self, mock_imread, mock_match_to_target
    ):
        """Test matching when some targets fail to load."""
        # Setup mock - first succeeds, second fails
        mock_img = np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8)
        mock_imread.side_effect = [mock_img, None]

        mock_match_to_target.return_value = [
            {
                'query_box': [10, 10, 30, 30],
                'target_box': [15, 15, 35, 35],
                'similarity': 0.85,
                'target_image': mock_img
            }
        ]

        # Test
        from modules.pattern_match import _match_against_targets

        matches = _match_against_targets(
            self.test_image, self.mock_query_features, self.target_images, 'texture'
        )

        # Verify - should only have matches from first target
        self.assertEqual(len(matches), 1)


class TestMatchToTargetImage(unittest.TestCase):
    """Tests for _match_to_target_image function."""

    def setUp(self):
        """Set up test fixtures."""
        self.test_image = np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8)
        self.test_target = np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8)
        self.mock_query_features = [
            {'box': [10, 10, 30, 30], 'feature': np.random.rand(128), 'index': 0}
        ]

    @patch('modules.pattern_match._match_single_feature')
    def test_match_to_target_image(self, mock_match_single):
        """Test matching features to target image."""
        # Setup mock
        mock_match_single.return_value = {
            'query_box': [10, 10, 30, 30],
            'target_box': [15, 15, 35, 35],
            'similarity': 0.85,
            'target_image': self.test_target
        }

        # Test
        from modules.pattern_match import _match_to_target_image

        matches = _match_to_target_image(
            self.test_image, self.mock_query_features, self.test_target, 'texture'
        )

        # Verify
        self.assertEqual(len(matches), 1)
        mock_match_single.assert_called_once()


class TestMatchSingleFeature(unittest.TestCase):
    """Tests for _match_single_feature function."""

    def setUp(self):
        """Set up test fixtures."""
        self.test_roi = np.random.randint(0, 255, (20, 20, 3), dtype=np.uint8)
        self.test_target = np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8)
        self.mock_query_feature = {
            'box': [10, 10, 30, 30],
            'feature': np.random.rand(128),
            'index': 0
        }

    @patch('modules.pattern_match._match_texture_or_edge')
    def test_match_single_feature_texture(self, mock_match_texture):
        """Test matching texture features."""
        mock_match_texture.return_value = {
            'query_box': [10, 10, 30, 30],
            'target_box': [15, 15, 35, 35],
            'similarity': 0.85,
            'target_image': self.test_target
        }

        from modules.pattern_match import _match_single_feature

        result = _match_single_feature(
            self.test_roi, self.test_target, self.mock_query_feature, 'texture'
        )

        self.assertIsNotNone(result)
        mock_match_texture.assert_called_once()

    @patch('modules.pattern_match._match_color')
    def test_match_single_feature_color(self, mock_match_color):
        """Test matching color features."""
        mock_match_color.return_value = {
            'query_box': [10, 10, 30, 30],
            'target_box': [25, 25, 75, 75],
            'similarity': 0.75,
            'target_image': self.test_target
        }

        from modules.pattern_match import _match_single_feature

        result = _match_single_feature(
            self.test_roi, self.test_target, self.mock_query_feature, 'color'
        )

        self.assertIsNotNone(result)
        mock_match_color.assert_called_once()

    @patch('modules.pattern_match._match_texture_or_edge')
    def test_match_single_feature_edge(self, mock_match_texture):
        """Test matching edge features."""
        mock_match_texture.return_value = {
            'query_box': [10, 10, 30, 30],
            'target_box': [15, 15, 35, 35],
            'similarity': 0.80,
            'target_image': self.test_target
        }

        from modules.pattern_match import _match_single_feature

        result = _match_single_feature(
            self.test_roi, self.test_target, self.mock_query_feature, 'edge'
        )

        self.assertIsNotNone(result)
        mock_match_texture.assert_called_once()

    def test_match_single_feature_invalid_type(self):
        """Test matching with invalid feature type."""
        from modules.pattern_match import _match_single_feature

        result = _match_single_feature(
            self.test_roi, self.test_target, self.mock_query_feature, 'invalid'
        )

        self.assertIsNone(result)


class TestMatchTextureOrEdge(unittest.TestCase):
    """Tests for _match_texture_or_edge function."""

    def setUp(self):
        """Set up test fixtures."""
        self.test_roi = np.random.randint(0, 255, (20, 20, 3), dtype=np.uint8)
        self.test_target = np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8)
        self.mock_query_feature = {
            'box': [10, 10, 30, 30],
            'feature': np.random.rand(128),
            'index': 0
        }

    @patch('cv2.matchTemplate')
    @patch('cv2.minMaxLoc')
    def test_match_texture_or_edge_success(self, mock_minMaxLoc, mock_matchTemplate):
        """Test successful texture/edge matching."""
        # Setup mock template matching
        mock_minMaxLoc.return_value = (0.0, 0.85, (15, 15), (25, 25))

        from modules.pattern_match import _match_texture_or_edge

        result = _match_texture_or_edge(
            self.test_roi, self.test_target, self.mock_query_feature
        )

        # Verify
        self.assertIsNotNone(result)
        self.assertEqual(result['similarity'], 0.85)
        self.assertEqual(result['target_box'], [25, 25, 45, 45])

    @patch('cv2.matchTemplate')
    @patch('cv2.minMaxLoc')
    def test_match_texture_or_edge_low_similarity(self, mock_minMaxLoc, mock_matchTemplate):
        """Test matching when similarity is below threshold."""
        # Setup mock template matching with low similarity
        mock_minMaxLoc.return_value = (0.0, 0.5, (15, 15), (25, 25))

        from modules.pattern_match import _match_texture_or_edge

        result = _match_texture_or_edge(
            self.test_roi, self.test_target, self.mock_query_feature
        )

        # Verify - should return None
        self.assertIsNone(result)


class TestMatchColor(unittest.TestCase):
    """Tests for _match_color function."""

    def setUp(self):
        """Set up test fixtures."""
        self.test_roi = np.random.randint(0, 255, (20, 20, 3), dtype=np.uint8)
        self.test_target = np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8)
        self.mock_query_feature = {
            'box': [10, 10, 30, 30],
            'feature': np.random.rand(96),
            'index': 0
        }

    @patch('modules.pattern_match.extract_pattern_feature')
    @patch('cv2.compareHist')
    def test_match_color_success(self, mock_compareHist, mock_extract_pattern):
        """Test successful color matching."""
        # Setup mocks
        mock_extract_pattern.return_value = np.random.rand(96)
        mock_compareHist.return_value = 0.85

        from modules.pattern_match import _match_color

        result = _match_color(self.test_roi, self.test_target, self.mock_query_feature)

        # Verify
        self.assertIsNotNone(result)
        self.assertEqual(result['similarity'], 0.85)

    @patch('modules.pattern_match.extract_pattern_feature')
    def test_match_color_low_similarity(self, mock_extract_pattern):
        """Test matching when similarity is below threshold."""
        # Setup mock
        mock_extract_pattern.return_value = np.random.rand(96)

        # Patch cv2.compareHist to return low similarity
        with patch('cv2.compareHist', return_value=0.6):
            from modules.pattern_match import _match_color

            result = _match_color(self.test_roi, self.test_target, self.mock_query_feature)

            # Verify - should return None
            self.assertIsNone(result)


class TestSortBySimilarity(unittest.TestCase):
    """Tests for _sort_by_similarity function."""

    def test_sort_by_similarity(self):
        """Test sorting matches by similarity."""
        matches = [
            {'query_box': [10, 10, 30, 30], 'similarity': 0.5},
            {'query_box': [20, 20, 40, 40], 'similarity': 0.9},
            {'query_box': [30, 30, 50, 50], 'similarity': 0.7}
        ]

        from modules.pattern_match import _sort_by_similarity

        sorted_matches = _sort_by_similarity(matches)

        # Verify - should be sorted descending
        self.assertEqual(sorted_matches[0]['similarity'], 0.9)
        self.assertEqual(sorted_matches[1]['similarity'], 0.7)
        self.assertEqual(sorted_matches[2]['similarity'], 0.5)


if __name__ == '__main__':
    unittest.main()
