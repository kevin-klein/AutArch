"""
Integration tests for the torch service.

These tests verify that components work together correctly.
"""

import unittest
from unittest.mock import Mock, patch
import numpy as np
import torch
from PIL import Image
import io
import json


class TestSimpleIntegration(unittest.TestCase):
    """Simple integration tests that verify module interactions."""

    def test_analysis_uses_registry(self):
        """Test that analysis module uses the registry correctly."""
        from unittest.mock import Mock
        import torch

        # Create mock registry
        mock_registry = Mock()
        mock_detection = Mock()
        mock_prediction = [{
            'boxes': torch.tensor([[10, 10, 80, 80]]),
            'scores': torch.tensor([0.95]),
            'labels': torch.tensor([0])
        }]
        mock_detection.return_value = mock_prediction
        mock_registry.detection_model = mock_detection
        mock_registry.label2id = {0: 'Arrow'}
        mock_registry.device = torch.device('cpu')

        # Patch registry where it's imported
        with patch('modules.analysis.registry', mock_registry):
            with patch('modules.analysis.PILToTensor') as mock_pil_to_tensor:
                mock_tensor = torch.rand(3, 224, 224)
                mock_pil_to_tensor.return_value = (mock_tensor, None)

                with patch('modules.analysis.Image.open') as mock_open:
                    test_image = Image.new('RGB', (100, 100), color='red')
                    mock_open.return_value = test_image

                    # Create mock file
                    mock_file = Mock()
                    buffer = io.BytesIO()
                    test_image.save(buffer, format='PNG')
                    buffer.seek(0)
                    mock_file.read.return_value = buffer.read()

                    # Run analysis
                    from modules.analysis import analyze_file
                    result = analyze_file(mock_file)

                    # Verify
                    self.assertIsInstance(result, list)
                    self.assertGreater(len(result), 0)
                    self.assertEqual(result[0]['label'], 'Arrow')

    def test_sam_uses_registry(self):
        """Test that SAM module uses the registry correctly."""
        from unittest.mock import Mock
        import numpy as np

        # Create mock registry
        mock_registry = Mock()

        # Setup SAM predictor mock
        mock_masks = np.random.rand(1, 100, 100)
        mock_masks[0, 30:70, 30:70] = 1
        mock_scores = np.array([0.95])
        mock_logits = None

        mock_predictor = Mock()
        mock_predictor.predict.return_value = (mock_masks, mock_scores, mock_logits)
        mock_registry.sam_predictor = mock_predictor

        # Patch registry
        with patch('modules.sam.registry', mock_registry):
            # Create mock file
            test_image = Image.new('RGB', (100, 100), color='blue')
            buffer = io.BytesIO()
            test_image.save(buffer, format='PNG')
            buffer.seek(0)

            mock_file = Mock()
            mock_file.file = io.BytesIO(buffer.read())

            # Run segmentation
            from modules.sam import segment_image
            points_json = json.dumps([[50, 50]])
            result = segment_image(mock_file, points_json)

            # Verify
            self.assertIn('predictions', result)
            self.assertIn('score', result['predictions'])
            self.assertGreater(result['predictions']['score'], 0.5)

    def test_routes_calls_analysis(self):
        """Test that routes module calls analysis functions."""
        from unittest.mock import Mock
        import io

        # Create mock file
        test_image = Image.new('RGB', (100, 100), color='yellow')
        buffer = io.BytesIO()
        test_image.save(buffer, format='PNG')
        buffer.seek(0)

        mock_file = Mock()
        mock_file.file = io.BytesIO(buffer.read())

        # Mock request
        mock_request = Mock()
        mock_request.POST = {'image': mock_file}

        # Mock analyze_file - patch both locations since routes imports the function
        mock_analyze = Mock()
        mock_analyze.return_value = [
            {'score': 0.95, 'box': [10, 10, 100, 100], 'label': 'Arrow'}
        ]

        with patch('modules.analysis.registry') as mock_registry:
            mock_registry.detection_model = Mock(return_value=[])
            mock_registry.label2id = {0: 'Arrow'}
            mock_registry.device = 'cpu'

            with patch('modules.routes.request', mock_request):
                with patch('modules.routes.analyze_file', mock_analyze):
                    from modules.routes import handle_upload
                    result = handle_upload()

                    # Verify
                    self.assertIn('predictions', result)
                    mock_analyze.assert_called_once()


class TestBOVWIntegration(unittest.TestCase):
    """BOVW integration tests."""

    def test_bovw_workflow(self):
        """Test complete BOVW training workflow."""
        import cv2
        import tempfile
        import os

        with tempfile.TemporaryDirectory() as temp_dir:
            # Create sample images
            image_paths = []
            for i in range(3):
                img = np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8)
                path = os.path.join(temp_dir, f'image{i}.jpg')
                cv2.imwrite(path, img)
                image_paths.append(path)

            # Mock feature extraction
            with patch('modules.bovw.extract_local_features') as mock_extract:
                mock_descriptors = np.random.rand(100, 128).astype(np.float32)
                mock_extract.return_value = (mock_descriptors, None)

                # Train vocabulary
                from modules.bovw import train_visual_vocabulary
                vocabulary = train_visual_vocabulary(
                    image_paths, n_clusters=16, feature_type='sift'
                )

                # Verify vocabulary trained
                self.assertIsNotNone(vocabulary)
                self.assertEqual(vocabulary.n_clusters, 16)

                # Compute features for new image
                new_img = np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8)
                mock_extract.return_value = (np.random.rand(50, 128).astype(np.float32), None)

                from modules.bovw import compute_bovw_features
                features, word_labels = compute_bovw_features(
                    new_img, vocabulary, feature_type='sift'
                )

                # Verify features computed
                self.assertIsInstance(features, list)
                self.assertEqual(len(features), 16)
                self.assertIsNotNone(word_labels)


class TestPatternMatchingIntegration(unittest.TestCase):
    """Pattern matching integration tests."""

    def test_pattern_workflow(self):
        """Test complete pattern matching workflow."""
        import numpy as np

        # Create test images
        query_img = np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8)
        target_img = np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8)

        pattern_boxes = [[10, 10, 30, 30]]
        target_images = ['target.jpg']

        with patch('modules.pattern_match._load_image') as mock_load:
            mock_load.side_effect = [query_img, target_img]

            with patch('modules.pattern_match._extract_query_features') as mock_extract:
                mock_extract.return_value = [
                    {'box': [10, 10, 30, 30], 'feature': np.random.rand(128), 'index': 0}
                ]

                with patch('modules.pattern_match._match_against_targets') as mock_match:
                    mock_match.return_value = [
                        {
                            'query_box': [10, 10, 30, 30],
                            'target_box': [15, 15, 35, 35],
                            'similarity': 0.85,
                            'target_image': target_img
                        }
                    ]

                    from modules.pattern_match import match_pattern_parts
                    result = match_pattern_parts(
                        'query.jpg', pattern_boxes, target_images, 'texture'
                    )

                    # Verify
                    self.assertTrue(result['success'])
                    self.assertEqual(result['n_query_patterns'], 1)
                    self.assertGreater(result['n_matches'], 0)
                    self.assertIsInstance(result['matches'], list)


class TestErrorPropagation(unittest.TestCase):
    """Test error propagation across modules."""

    def test_analysis_error_propagation(self):
        """Test that errors propagate from analysis to routes."""
        from unittest.mock import Mock
        import io

        # Create mock file
        test_image = Image.new('RGB', (100, 100), color='yellow')
        buffer = io.BytesIO()
        test_image.save(buffer, format='PNG')
        buffer.seek(0)

        mock_file = Mock()
        mock_file.file = io.BytesIO(buffer.read())

        # Mock request
        mock_request = Mock()
        mock_request.POST = {'image': mock_file}

        # Mock analyze_file to raise error - patch at routes since that's where it's imported
        mock_analyze = Mock()
        mock_analyze.side_effect = ValueError("Analysis failed")

        with patch('modules.analysis.registry') as mock_registry:
            mock_registry.detection_model = Mock(return_value=[])
            mock_registry.label2id = {0: 'Arrow'}
            mock_registry.device = 'cpu'

            with patch('modules.routes.request', mock_request):
                with patch('modules.routes.analyze_file', mock_analyze):
                    from modules.routes import handle_upload
                    # Verify that the error propagates (not caught)
                    with self.assertRaises(ValueError) as context:
                        handle_upload()
                    self.assertEqual(str(context.exception), "Analysis failed")

    def test_bovw_error_handling(self):
        """Test BOVW error handling."""
        import cv2
        import tempfile
        import os

        with tempfile.TemporaryDirectory() as temp_dir:
            # Create one valid image
            img = np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8)
            path = os.path.join(temp_dir, 'valid.jpg')
            cv2.imwrite(path, img)

            image_paths = [path, 'nonexistent.jpg']

            # Mock extract_local_features to return None
            with patch('modules.bovw.extract_local_features') as mock_extract:
                mock_extract.return_value = (None, None)

                from modules.bovw import train_visual_vocabulary

                with self.assertRaises(ValueError):
                    train_visual_vocabulary(image_paths, n_clusters=16)

    def test_pattern_match_error_handling(self):
        """Test pattern match error handling."""
        # Mock _load_image to raise error
        with patch('modules.pattern_match._load_image') as mock_load:
            mock_load.side_effect = ValueError("Image not found")

            from modules.pattern_match import match_pattern_parts

            with self.assertRaises(ValueError):
                match_pattern_parts(
                    'nonexistent.jpg',
                    [[10, 10, 30, 30]],
                    ['target.jpg'],
                    'texture'
                )


if __name__ == '__main__':
    unittest.main()
