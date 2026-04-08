"""
Unit tests for the routes module (Bottle HTTP handlers).
"""

import unittest
from unittest.mock import Mock, patch, MagicMock
import json
from io import BytesIO


class MockUploadFile:
    """Mock file object from Bottle request.POST."""

    def __init__(self, content):
        self.content = content
        self.file = BytesIO(content)


class TestHandleSegment(unittest.TestCase):
    """Tests for handle_segment function."""

    def setUp(self):
        """Set up test fixtures."""
        self.test_image = b'test_image_data'
        self.points_json = json.dumps([[25, 25], [50, 50]])
        self.mock_upload_file = MockUploadFile(self.test_image)

    @patch('modules.routes.segment_image')
    @patch('modules.routes.request')
    def test_handle_segment_success(self, mock_request, mock_segment):
        """Test successful segment handling."""
        # Setup mocks
        mock_request.POST = {
            'image': self.mock_upload_file,
            'points': self.points_json
        }

        mock_segment.return_value = {
            'predictions': {
                'score': 0.95,
                'contour': [[[10, 10], [20, 20], [30, 30]]]
            }
        }

        # Test - import after patching
        from modules.routes import handle_segment

        result = handle_segment()

        # Verify
        self.assertIn('predictions', result)
        self.assertIn('score', result['predictions'])
        self.assertIn('contour', result['predictions'])
        mock_segment.assert_called_once_with(self.mock_upload_file, self.points_json)

    @patch('modules.routes.segment_image')
    @patch('modules.routes.request')
    def test_handle_segment_error(self, mock_request, mock_segment):
        """Test segment handling with error propagates."""
        # Setup mocks
        mock_request.POST = {
            'image': self.mock_upload_file,
            'points': self.points_json
        }

        mock_segment.side_effect = ValueError("Segmentation failed")

        # Test - error should propagate (no try/except in handle_segment)
        from modules.routes import handle_segment

        with self.assertRaises(ValueError):
            handle_segment()


class TestHandleUpload(unittest.TestCase):
    """Tests for handle_upload function."""

    def setUp(self):
        """Set up test fixtures."""
        self.test_image = b'test_image_data'
        self.mock_upload_file = MockUploadFile(self.test_image)

    @patch('modules.routes.analyze_file')
    @patch('modules.routes.request')
    def test_handle_upload_success(self, mock_request, mock_analyze):
        """Test successful upload handling."""
        # Setup mocks
        mock_request.POST = {'image': self.mock_upload_file}

        mock_analyze.return_value = [
            {'score': 0.95, 'box': [10, 10, 100, 100], 'label': 'Arrow'}
        ]

        # Test
        from modules.routes import handle_upload

        result = handle_upload()

        # Verify
        self.assertIn('predictions', result)
        self.assertIsInstance(result['predictions'], list)
        self.assertGreater(len(result['predictions']), 0)
        mock_analyze.assert_called_once_with(self.mock_upload_file.file)

    @patch('modules.routes.analyze_file')
    @patch('modules.routes.request')
    def test_handle_upload_empty(self, mock_request, mock_analyze):
        """Test upload handling with no predictions."""
        # Setup mocks
        mock_request.POST = {'image': self.mock_upload_file}

        mock_analyze.return_value = []

        # Test
        from modules.routes import handle_upload

        result = handle_upload()

        # Verify
        self.assertIn('predictions', result)
        self.assertEqual(len(result['predictions']), 0)


class TestHandleArrow(unittest.TestCase):
    """Tests for handle_arrow function."""

    def setUp(self):
        """Set up test fixtures."""
        self.test_image = b'test_image_data'
        self.mock_upload_file = MockUploadFile(self.test_image)

    @patch('modules.routes.analyze_arrow')
    @patch('modules.routes.request')
    def test_handle_arrow_success(self, mock_request, mock_analyze):
        """Test successful arrow handling."""
        # Setup mocks
        mock_request.POST = {'image': self.mock_upload_file}

        import torch
        mock_analyze.return_value = torch.tensor([[0.707, 0.707]])

        # Test
        from modules.routes import handle_arrow

        result = handle_arrow()

        # Verify
        self.assertIn('predictions', result)
        # Use approximate comparison for floats
        self.assertAlmostEqual(result['predictions'][0], 0.707, places=3)
        self.assertAlmostEqual(result['predictions'][1], 0.707, places=3)
        mock_analyze.assert_called_once_with(self.mock_upload_file.file)


class TestHandleSkeleton(unittest.TestCase):
    """Tests for handle_skeleton function."""

    def setUp(self):
        """Set up test fixtures."""
        self.test_image = b'test_image_data'
        self.mock_upload_file = MockUploadFile(self.test_image)

    @patch('modules.routes.analyze_skeleton')
    @patch('modules.routes.request')
    def test_handle_skeleton_success(self, mock_request, mock_analyze):
        """Test successful skeleton handling."""
        # Setup mocks
        mock_request.POST = {'image': self.mock_upload_file}

        mock_analyze.return_value = 'right'

        # Test
        from modules.routes import handle_skeleton

        result = handle_skeleton()

        # Verify
        self.assertIn('predictions', result)
        self.assertEqual(result['predictions'], 'right')
        mock_analyze.assert_called_once_with(self.mock_upload_file.file)


class TestHandleEFD(unittest.TestCase):
    """Tests for handle_efd function."""

    def setUp(self):
        """Set up test fixtures."""
        self.efd_data = {
            'contour': [[10, 10], [20, 20], [30, 30], [40, 40]],
            'order': 15,
            'normalize': True,
            'return_transformation': False
        }

    @patch('modules.routes.request')
    @patch('pyefd.elliptic_fourier_descriptors')
    def test_handle_efd_success(self, mock_efd, mock_request):
        """Test successful EFD handling."""
        import numpy as np

        # Setup mocks
        mock_request.json = self.efd_data

        mock_coeffs = np.random.rand(16, 3)
        mock_efd.return_value = mock_coeffs

        # Test
        from modules.routes import handle_efd

        result = handle_efd()

        # Verify
        self.assertIn('efds', result)
        self.assertIsInstance(result['efds'], list)
        mock_efd.assert_called_once_with(
            self.efd_data['contour'],
            order=self.efd_data['order'],
            normalize=self.efd_data['normalize'],
            return_transformation=self.efd_data['return_transformation']
        )


class TestHandleTrainBOVW(unittest.TestCase):
    """Tests for handle_train_bovw function."""

    def setUp(self):
        """Set up test fixtures."""
        self.bovw_data = {
            'images': ['image1.jpg', 'image2.jpg', 'image3.jpg'],
            'n_clusters': 32,
            'feature_type': 'sift'
        }

    @patch('modules.routes.compute_similarity_matrix')
    @patch('modules.routes.train_visual_vocabulary')
    @patch('modules.routes.request')
    def test_handle_train_bovw_success(
        self, mock_request, mock_train_vocab, mock_compute_sim
    ):
        """Test successful BOVW training."""
        import numpy as np

        # Setup mocks properly
        mock_request.POST = {}
        mock_request.json = self.bovw_data

        mock_vocabulary = Mock()
        mock_vocabulary.n_clusters = 32
        mock_train_vocab.return_value = mock_vocabulary

        mock_compute_sim.return_value = (
            np.random.rand(3, 3).tolist(),
            ['image1.jpg', 'image2.jpg', 'image3.jpg']
        )

        # Test
        from modules.routes import handle_train_bovw

        result = handle_train_bovw()

        # Verify
        self.assertTrue(result['success'])
        self.assertEqual(result['n_clusters'], 32)
        self.assertEqual(result['n_images'], 3)
        self.assertIn('similarity_matrix', result)

    @patch('modules.routes.train_visual_vocabulary')
    @patch('modules.routes.request')
    def test_handle_train_bovw_error(self, mock_request, mock_train_vocab):
        """Test BOVW training with error."""
        # Setup mocks
        mock_request.json = self.bovw_data

        mock_train_vocab.side_effect = ValueError("Training failed")

        # Test
        from modules.routes import handle_train_bovw

        result = handle_train_bovw()

        # Verify
        self.assertFalse(result['success'])
        self.assertIn('error', result)
        self.assertIn('traceback', result)

    @patch('modules.routes.compute_similarity_matrix')
    @patch('modules.routes.train_visual_vocabulary')
    @patch('modules.routes.request')
    def test_handle_train_bovw_default_params(
        self, mock_request, mock_train_vocab, mock_compute_sim
    ):
        """Test BOVW training with default parameters."""
        import numpy as np

        # Setup mocks properly
        mock_request.POST = {}
        mock_request.json = {'images': ['image1.jpg']}

        mock_vocabulary = Mock()
        mock_vocabulary.n_clusters = 32
        mock_train_vocab.return_value = mock_vocabulary

        # Return value must be a tuple that can be unpacked
        mock_compute_sim.return_value = (
            np.random.rand(1, 1).tolist(),
            ['image1.jpg']
        )

        # Test
        from modules.routes import handle_train_bovw

        result = handle_train_bovw()
        print(f"DEBUG: result = {result}")
        print(f"DEBUG: mock_train_vocab.called = {mock_train_vocab.called}")
        print(f"DEBUG: mock_train_vocab.call_args = {mock_train_vocab.call_args}")
        print(f"DEBUG: mock_compute_sim.called = {mock_compute_sim.called}")
        print(f"DEBUG: mock_compute_sim.return_value = {mock_compute_sim.return_value}")

        # Verify
        self.assertTrue(result['success'], f"Expected success but got: {result}")
        self.assertEqual(result['feature_type'], 'sift')


class TestHandlePatternMatch(unittest.TestCase):
    """Tests for handle_pattern_match function."""

    def setUp(self):
        """Set up test fixtures."""
        self.pattern_data = {
            'query_image': 'query.jpg',
            'pattern_boxes': [[10, 10, 30, 30], [50, 50, 70, 70]],
            'target_images': ['target1.jpg', 'target2.jpg'],
            'feature_type': 'texture'
        }

    @patch('modules.routes.match_pattern_parts')
    @patch('modules.routes.request')
    def test_handle_pattern_match_success(
        self, mock_request, mock_match
    ):
        """Test successful pattern matching."""
        # Setup mocks
        mock_request.json = self.pattern_data

        mock_match.return_value = {
            'success': True,
            'n_query_patterns': 2,
            'n_matches': 5,
            'matches': []
        }

        # Test
        from modules.routes import handle_pattern_match

        result = handle_pattern_match()

        # Verify
        self.assertTrue(result['success'])
        self.assertEqual(result['n_query_patterns'], 2)
        self.assertEqual(result['n_matches'], 5)
        mock_match.assert_called_once_with(
            'query.jpg',
            [[10, 10, 30, 30], [50, 50, 70, 70]],
            ['target1.jpg', 'target2.jpg'],
            'texture'
        )

    @patch('modules.routes.match_pattern_parts')
    @patch('modules.routes.request')
    def test_handle_pattern_match_no_boxes(
        self, mock_request, mock_match
    ):
        """Test pattern matching with no pattern boxes."""
        # Setup mocks
        mock_request.json = {
            'query_image': 'query.jpg',
            'pattern_boxes': [],
            'target_images': ['target1.jpg']
        }

        # Test
        from modules.routes import handle_pattern_match

        result = handle_pattern_match()

        # Verify - should return error
        self.assertFalse(result['success'])
        self.assertIn('error', result)

    @patch('modules.routes.match_pattern_parts')
    @patch('modules.routes.request')
    def test_handle_pattern_match_error(
        self, mock_request, mock_match
    ):
        """Test pattern matching with exception."""
        # Setup mocks
        mock_request.json = self.pattern_data

        mock_match.side_effect = ValueError("Matching failed")

        # Test
        from modules.routes import handle_pattern_match

        result = handle_pattern_match()

        # Verify
        self.assertFalse(result['success'])
        self.assertIn('error', result)
        self.assertIn('traceback', result)


if __name__ == '__main__':
    unittest.main()
