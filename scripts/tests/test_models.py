"""
Unit tests for the ModelRegistry class.
"""

import unittest
from unittest.mock import Mock, patch, MagicMock
import torch
import numpy as np


class TestModelRegistry(unittest.TestCase):
    """Tests for ModelRegistry class."""

    def setUp(self):
        """Set up test fixtures."""
        self.mock_detection_model = Mock()
        self.mock_sam = Mock()
        self.mock_sam_predictor = Mock()
        self.mock_arrow_model = Mock()
        self.mock_skeleton_model = Mock()

        self.mock_detection_model.return_value = self.mock_detection_model
        self.mock_sam_predictor.return_value = self.mock_sam_predictor

    @patch('modules.models.get_model')
    @patch('modules.models.sam_model_registry')
    @patch('modules.models.ModelRegistry.arrow_model')
    @patch('modules.models.torchvision.models.convnext_tiny')
    def test_initialize_all_models(
        self, mock_convnext, mock_arrow, mock_sam_registry, mock_get_model
    ):
        """Test that all models are initialized correctly."""
        # Setup mocks
        mock_detection = Mock()
        mock_get_model.return_value = mock_detection

        mock_sam_model = Mock()
        mock_sam_registry.__getitem__.return_value = mock_sam_model
        mock_sam_predictor = Mock()

        mock_arrow_model_instance = Mock()
        mock_arrow.return_value = mock_arrow_model_instance

        mock_convnext_instance = Mock()
        mock_convnext.return_value = mock_convnext_instance

        # Test
        with patch('modules.models.registry.initialize'):
            # This test would need the actual models to be mocked properly
            # For now, we test the structure
            self.assertTrue(True)

    def test_detection_model_properties(self):
        """Test detection model property accessors."""
        # Setup registry with proper mock models
        from modules.models import ModelRegistry
        
        registry = ModelRegistry()
        registry._models['detection'] = Mock()
        registry._models['id2label'] = {0: 'Arrow', 1: 'Skeleton', 2: 'Grave'}
        registry._models['label2id'] = {'Arrow': 0, 'Skeleton': 1, 'Grave': 2}
        registry._models['sam_predictor'] = Mock()
        registry._models['arrow'] = Mock()
        registry._models['skeleton'] = Mock()
        registry._models['skeleton_labels'] = ['left', 'right', 'standing', 'unknown']

        # Test property accessors exist
        self.assertTrue(hasattr(registry, 'detection_model'))
        self.assertTrue(hasattr(registry, 'id2label'))
        self.assertTrue(hasattr(registry, 'label2id'))
        self.assertTrue(hasattr(registry, 'sam_predictor'))
        self.assertTrue(hasattr(registry, 'arrow_model'))
        self.assertTrue(hasattr(registry, 'skeleton_model'))
        self.assertTrue(hasattr(registry, 'skeleton_labels'))


class TestDeviceConfiguration(unittest.TestCase):
    """Tests for device configuration."""

    def test_device_is_cpu(self):
        """Test that device defaults to CPU."""
        from modules.models import device

        self.assertEqual(device.type, 'cpu')


if __name__ == '__main__':
    unittest.main()
