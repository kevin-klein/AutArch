"""
Unit tests for the analysis module.
"""

import unittest
from unittest.mock import Mock, patch, MagicMock
import torch
import numpy as np
from PIL import Image
import io


class TestAnalyzeFile(unittest.TestCase):
    """Tests for analyze_file function."""

    @patch('modules.analysis._load_image_from_file')
    @patch('modules.analysis._convert_to_tensor')
    @patch('modules.analysis.registry')
    def test_analyze_file_success(self, mock_registry, mock_convert, mock_load):
        """Test successful object detection analysis."""
        # Setup mock PIL image
        mock_pil_image = Mock(spec=Image.Image)
        mock_load.return_value = mock_pil_image

        # Setup tensor conversion
        mock_tensor = torch.rand(3, 224, 224)
        mock_convert.return_value = mock_tensor

        # Setup model prediction
        mock_prediction = [{
            'boxes': torch.tensor([[10.0, 10.0, 100.0, 100.0]]),
            'scores': torch.tensor([0.95]),
            'labels': torch.tensor([0])
        }]

        mock_model = Mock()
        mock_model.return_value = mock_prediction
        mock_registry.detection_model = mock_model
        mock_registry.label2id = {0: 'Arrow', 1: 'Skeleton'}
        mock_registry.device = torch.device('cpu')

        # Setup mock file object
        mock_file = Mock()

        # Test
        from modules.analysis import analyze_file

        result = analyze_file(mock_file)

        # Verify
        self.assertIsInstance(result, list)
        self.assertGreater(len(result), 0)
        self.assertIn('score', result[0])
        self.assertIn('box', result[0])
        self.assertIn('label', result[0])
        self.assertEqual(result[0]['label'], 'Arrow')
        self.assertEqual(result[0]['score'], 0.95)

    @patch('modules.analysis._load_image_from_file')
    @patch('modules.analysis._convert_to_tensor')
    @patch('modules.analysis.registry')
    def test_analyze_file_low_score_filtered(self, mock_registry, mock_convert, mock_load):
        """Test that low score predictions are filtered out."""
        # Setup mock PIL image
        mock_pil_image = Mock(spec=Image.Image)
        mock_load.return_value = mock_pil_image

        # Setup tensor conversion
        mock_tensor = torch.rand(3, 224, 224)
        mock_convert.return_value = mock_tensor

        # Setup model prediction with low scores
        mock_prediction = [{
            'boxes': torch.tensor([[10.0, 10.0, 100.0, 100.0]]),
            'scores': torch.tensor([0.05]),  # Below threshold
            'labels': torch.tensor([0])
        }]

        mock_model = Mock()
        mock_model.return_value = mock_prediction
        mock_registry.detection_model = mock_model
        mock_registry.label2id = {0: 'Arrow'}
        mock_registry.device = torch.device('cpu')

        # Setup mock file object
        mock_file = Mock()

        # Test
        from modules.analysis import analyze_file

        result = analyze_file(mock_file)

        # Verify - should be empty due to low score
        self.assertEqual(len(result), 0)


class TestAnalyzeArrow(unittest.TestCase):
    """Tests for analyze_arrow function."""

    @patch('modules.analysis._load_image_from_file')
    @patch('modules.analysis._convert_to_tensor')
    @patch('modules.analysis.registry')
    def test_analyze_arrow_success(self, mock_registry, mock_convert, mock_load):
        """Test successful arrow orientation analysis."""
        # Setup mock PIL image
        mock_pil_image = Mock(spec=Image.Image)
        mock_load.return_value = mock_pil_image

        # Setup tensor conversion
        mock_tensor = torch.rand(1, 3, 224, 224)
        mock_convert.return_value = mock_tensor

        # Setup model prediction
        mock_prediction = torch.tensor([[0.707, 0.707]])  # cos, sin for 45 degrees
        mock_registry.arrow_model.return_value = mock_prediction
        mock_registry.arrow_model.eval = Mock()
        mock_registry.device = torch.device('cpu')

        # Setup mock file object
        mock_file = Mock()

        # Test
        from modules.analysis import analyze_arrow

        result = analyze_arrow(mock_file)

        # Verify
        self.assertIsInstance(result, torch.Tensor)
        self.assertEqual(result.shape[0], 1)
        self.assertEqual(result.shape[1], 2)

    @patch('modules.analysis._load_image_from_file')
    @patch('modules.analysis._convert_to_tensor')
    @patch('modules.analysis.registry')
    def test_analyze_arrow_evaluation_mode(self, mock_registry, mock_convert, mock_load):
        """Test that arrow model is set to eval mode."""
        # Setup mock PIL image
        mock_pil_image = Mock(spec=Image.Image)
        mock_load.return_value = mock_pil_image

        # Setup tensor conversion
        mock_tensor = torch.rand(1, 3, 224, 224)
        mock_convert.return_value = mock_tensor

        # Setup model prediction
        mock_prediction = torch.tensor([[0.5, 0.866]])
        mock_registry.arrow_model.return_value = mock_prediction

        # Setup mock file object
        mock_file = Mock()

        # Test
        from modules.analysis import analyze_arrow

        analyze_arrow(mock_file)

        # Verify eval mode was called
        mock_registry.arrow_model.eval.assert_called_once()


class TestAnalyzeSkeleton(unittest.TestCase):
    """Tests for analyze_skeleton function."""

    @patch('modules.analysis._load_image_from_file')
    @patch('modules.analysis._convert_to_tensor')
    @patch('modules.analysis.registry')
    def test_analyze_skeleton_success(self, mock_registry, mock_convert, mock_load):
        """Test successful skeleton classification."""
        # Setup mock PIL image
        mock_pil_image = Mock(spec=Image.Image)
        mock_load.return_value = mock_pil_image

        # Setup tensor conversion
        mock_tensor = torch.rand(1, 3, 224, 224)
        mock_convert.return_value = mock_tensor

        # Setup model prediction
        mock_prediction = torch.tensor([[0.1, 0.8, 0.05, 0.05]])  # 'right' has highest
        mock_skeleton_labels = ['left', 'right', 'standing', 'unknown']
        mock_registry.skeleton_model.return_value = mock_prediction
        mock_registry.skeleton_model.eval = Mock()
        mock_registry.skeleton_labels = mock_skeleton_labels
        mock_registry.device = torch.device('cpu')

        # Setup mock file object
        mock_file = Mock()

        # Test
        from modules.analysis import analyze_skeleton

        result = analyze_skeleton(mock_file)

        # Verify
        self.assertEqual(result, 'right')

    @patch('modules.analysis._load_image_from_file')
    @patch('modules.analysis._convert_to_tensor')
    @patch('modules.analysis.registry')
    def test_analyze_skeleton_max_prediction(self, mock_registry, mock_convert, mock_load):
        """Test that max prediction is selected."""
        # Setup mock PIL image
        mock_pil_image = Mock(spec=Image.Image)
        mock_load.return_value = mock_pil_image

        # Setup tensor conversion
        mock_tensor = torch.rand(1, 3, 224, 224)
        mock_convert.return_value = mock_tensor

        # Setup model prediction - need to mock max operation
        mock_prediction = torch.tensor([[0.1, 0.8, 0.05, 0.05]])
        mock_registry.skeleton_model.return_value = mock_prediction
        mock_registry.skeleton_model.eval = Mock()
        mock_registry.skeleton_labels = ['left', 'right', 'standing', 'unknown']
        mock_registry.device = torch.device('cpu')

        # Setup mock file object
        mock_file = Mock()

        # Test
        from modules.analysis import analyze_skeleton

        result = analyze_skeleton(mock_file)

        # Verify
        self.assertEqual(result, 'right')


class TestExtractObjectFeatures(unittest.TestCase):
    """Tests for extract_object_features function."""

    @patch('modules.analysis._compute_bovw_with_preprocessing')
    @patch('modules.analysis.Image.open')
    def test_extract_object_features_with_bovw(self, mock_open, mock_bovw):
        """Test feature extraction with BOVW vocabulary."""
        # Setup mock file object with read method that returns valid image data
        test_image = Image.new('RGB', (100, 100), color='green')
        buffer = io.BytesIO()
        test_image.save(buffer, format='PNG')
        buffer.seek(0)
        
        mock_file = Mock()
        mock_file.read.return_value = buffer.read()

        # Setup BOVW feature extraction mock to return specific values
        mock_bovw.return_value = (np.random.rand(32).tolist(), None)

        # Setup mock vocabulary
        mock_vocabulary = Mock()

        # Test
        from modules.analysis import extract_object_features

        result = extract_object_features(mock_file, mock_vocabulary)

        # Verify
        self.assertIsInstance(result, list)
        self.assertEqual(len(result), 32)
        mock_bovw.assert_called_once()

    @patch('modules.analysis._extract_backbone_features')
    @patch('modules.analysis._compute_bovw_with_preprocessing')
    @patch('modules.analysis.Image.open')
    def test_extract_object_features_fallback_to_backbone(self, mock_open, mock_bovw, mock_backbone):
        """Test feature extraction falls back to backbone when BOVW fails."""
        # Setup mock file object with read method that returns valid image data
        test_image = Image.new('RGB', (100, 100), color='green')
        buffer = io.BytesIO()
        test_image.save(buffer, format='PNG')
        buffer.seek(0)
        
        mock_file = Mock()
        mock_file.read.return_value = buffer.read()

        # Setup BOVW to raise exception
        mock_bovw.side_effect = Exception("BOVW failed")

        # Setup backbone mock
        mock_backbone.return_value = torch.rand(1, 384, 7, 7)

        # Setup mock vocabulary
        mock_vocabulary = Mock()

        # Test
        from modules.analysis import extract_object_features

        result = extract_object_features(mock_file, mock_vocabulary)

        # Verify - should be a tensor (backbone features)
        self.assertIsInstance(result, torch.Tensor)


class TestImageLoadingAndConversion(unittest.TestCase):
    """Tests for helper functions in analysis module."""

    def test_load_image_from_file(self):
        """Test loading PIL Image from file object."""
        # Create a simple test image
        test_image = Image.new('RGB', (100, 100), color='red')
        buffer = io.BytesIO()
        test_image.save(buffer, format='PNG')
        buffer.seek(0)

        mock_file = Mock()
        mock_file.read.return_value = buffer.read()

        from modules.analysis import _load_image_from_file

        result = _load_image_from_file(mock_file)

        self.assertIsInstance(result, Image.Image)
        self.assertEqual(result.size, (100, 100))

    @patch('modules.analysis.PILToTensor')
    def test_convert_to_tensor(self, mock_pil_to_tensor):
        """Test converting PIL Image to tensor."""
        # Create a real PIL image for proper tensor conversion
        test_image = Image.new('RGB', (224, 224), color='blue')
        
        # Mock PILToTensor to return a tensor
        mock_tensor = torch.rand(3, 224, 224)
        mock_pil_to_tensor.return_value = (mock_tensor, None)

        from modules.analysis import _convert_to_tensor

        result = _convert_to_tensor(test_image)

        self.assertIsInstance(result, torch.Tensor)
        self.assertEqual(result.shape[0], 1)  # Batch dimension


if __name__ == '__main__':
    unittest.main()
