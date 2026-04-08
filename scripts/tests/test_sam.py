"""
Unit tests for the SAM (Segment Anything Model) module.
"""

import unittest
from unittest.mock import Mock, patch, MagicMock
import torch
import numpy as np
from PIL import Image
import io
import json


class TestSegmentImage(unittest.TestCase):
    """Tests for segment_image function."""

    def setUp(self):
        """Set up test fixtures."""
        # Create a simple test image
        self.test_image = Image.new('RGB', (100, 100), color='blue')
        buffer = io.BytesIO()
        self.test_image.save(buffer, format='PNG')
        buffer.seek(0)

        self.mock_file = Mock()
        self.mock_file.file.read.return_value = buffer.read()

        self.mock_points = [[25, 25], [50, 50]]
        self.mock_points_json = json.dumps(self.mock_points)

    @patch('modules.sam.registry')
    def test_segment_image_success(self, mock_registry):
        """Test successful SAM segmentation."""
        # Setup mock SAM predictor
        mock_predictor = Mock()
        mock_registry.sam_predictor = mock_predictor

        # Setup mock mask output
        mock_masks = np.random.rand(1, 100, 100)
        mock_scores = torch.tensor([0.95])

        mock_predictor.predict.return_value = (mock_masks, mock_scores, None)

        # Test
        from modules.sam import segment_image

        result = segment_image(self.mock_file, self.mock_points_json)

        # Verify
        self.assertIn('predictions', result)
        self.assertIn('score', result['predictions'])
        self.assertIn('contour', result['predictions'])
        self.assertGreater(result['predictions']['score'], 0)
        self.assertIsInstance(result['predictions']['contour'], list)

    @patch('modules.sam.registry')
    def test_segment_image_sets_sam_image(self, mock_registry):
        """Test that SAM image is set correctly."""
        # Setup mock SAM predictor
        mock_predictor = Mock()
        mock_registry.sam_predictor = mock_predictor

        # Setup mock mask output
        mock_masks = np.random.rand(1, 100, 100)
        mock_scores = torch.tensor([0.95])

        mock_predictor.predict.return_value = (mock_masks, mock_scores, None)

        # Test
        from modules.sam import segment_image

        segment_image(self.mock_file, self.mock_points_json)

        # Verify set_image was called
        mock_predictor.set_image.assert_called_once()

    @patch('modules.sam.registry')
    def test_segment_image_with_multiple_contours(self, mock_registry):
        """Test segmentation with multiple contours."""
        # Setup mock SAM predictor
        mock_predictor = Mock()
        mock_registry.sam_predictor = mock_predictor

        # Setup mock with multiple masks
        mock_masks = np.random.rand(3, 100, 100)
        mock_scores = torch.tensor([0.3, 0.8, 0.6])

        mock_predictor.predict.return_value = (mock_masks, mock_scores, None)

        # Test
        from modules.sam import segment_image

        result = segment_image(self.mock_file, self.mock_points_json)

        # Verify - should select best mask
        self.assertIn('predictions', result)
        self.assertIn('contour', result['predictions'])
        self.assertIsInstance(result['predictions']['contour'], list)


class TestParsePoints(unittest.TestCase):
    """Tests for _parse_points function."""

    def test_parse_points_valid(self):
        """Test parsing valid points JSON."""
        points_json = json.dumps([[10, 20], [30, 40], [50, 60]])

        from modules.sam import _parse_points

        result = _parse_points(points_json)

        self.assertEqual(result, [[10, 20], [30, 40], [50, 60]])

    def test_parse_points_empty(self):
        """Test parsing empty points."""
        points_json = json.dumps([])

        from modules.sam import _parse_points

        result = _parse_points(points_json)

        self.assertEqual(result, [])

    def test_parse_points_invalid_json(self):
        """Test parsing invalid JSON."""
        points_json = "invalid json"

        from modules.sam import _parse_points

        with self.assertRaises(json.JSONDecodeError):
            _parse_points(points_json)


class TestPreparePoints(unittest.TestCase):
    """Tests for _prepare_points function."""

    def test_prepare_points_single(self):
        """Test preparing single point."""
        points = [[25, 25]]

        from modules.sam import _prepare_points

        input_point, input_label = _prepare_points(points)

        self.assertEqual(input_point.shape[0], 1)
        self.assertEqual(input_label.shape[0], 1)
        self.assertEqual(input_label[0], 1)  # Point label should be 1

    def test_prepare_points_multiple(self):
        """Test preparing multiple points."""
        points = [[10, 10], [20, 20], [30, 30]]

        from modules.sam import _prepare_points

        input_point, input_label = _prepare_points(points)

        self.assertEqual(input_point.shape[0], 3)
        self.assertEqual(input_label.shape[0], 3)
        self.assertTrue(np.all(input_label == 1))  # All points should have label 1


class TestSelectBestMask(unittest.TestCase):
    """Tests for _select_best_mask function."""

    def test_select_best_mask_largest(self):
        """Test selecting largest mask."""
        # Create masks with different sizes
        masks = np.zeros((3, 100, 100), dtype=bool)

        # Mask 0: small
        masks[0, 10:20, 10:20] = True  # 10x10 = 100 pixels

        # Mask 1: largest
        masks[1, 30:70, 30:70] = True  # 40x40 = 1600 pixels

        # Mask 2: medium
        masks[2, 50:80, 50:80] = True  # 30x30 = 900 pixels

        scores = torch.tensor([0.8, 0.9, 0.85])

        from modules.sam import _select_best_mask

        best_mask, best_score = _select_best_mask(masks, scores)

        # Should select mask 1 (largest)
        self.assertEqual(best_mask.shape, (100, 100))
        self.assertEqual(best_score, scores[1])

    def test_select_best_mask_single(self):
        """Test selecting from single mask."""
        masks = np.zeros((1, 100, 100), dtype=bool)
        masks[0, 10:20, 10:20] = True

        scores = torch.tensor([0.95])

        from modules.sam import _select_best_mask

        best_mask, best_score = _select_best_mask(masks, scores)

        self.assertEqual(best_score, scores[0])


class TestExtractContour(unittest.TestCase):
    """Tests for _extract_contour function."""

    def test_extract_contour_single_blob(self):
        """Test extracting contour from single blob."""
        mask = np.zeros((100, 100), dtype=bool)
        mask[30:70, 30:70] = True

        from modules.sam import _extract_contour

        contours = _extract_contour(mask)

        self.assertIsInstance(contours, list)
        self.assertGreater(len(contours), 0)

    def test_extract_contour_multiple_blobs(self):
        """Test extracting contours from multiple blobs."""
        mask = np.zeros((100, 100), dtype=bool)
        mask[10:20, 10:20] = True  # First blob
        mask[80:90, 80:90] = True  # Second blob

        from modules.sam import _extract_contour

        contours = _extract_contour(mask)

        self.assertIsInstance(contours, list)
        self.assertEqual(len(contours), 2)

    def test_extract_contour_empty(self):
        """Test extracting contour from empty mask."""
        mask = np.zeros((100, 100), dtype=bool)

        from modules.sam import _extract_contour

        contours = _extract_contour(mask)

        self.assertIsInstance(contours, list)


class TestSaveMasksAsImages(unittest.TestCase):
    """Tests for save_masks_as_images function."""

    def test_save_masks_as_images_creates_directory(self):
        """Test that function creates output directory."""
        import tempfile
        import shutil

        temp_dir = tempfile.mkdtemp()
        output_dir = tempfile.mkdtemp(dir=temp_dir)

        try:
            masks = np.random.rand(3, 100, 100) > 0.5

            from modules.sam import save_masks_as_images

            save_masks_as_images(masks, output_dir)

            # Verify files were created
            import os
            files = os.listdir(output_dir)
            self.assertEqual(len(files), 3)
        finally:
            shutil.rmtree(temp_dir)

    def test_save_masks_as_images_torch_tensor(self):
        """Test saving torch tensor masks."""
        import tempfile
        import shutil

        temp_dir = tempfile.mkdtemp()

        try:
            masks = torch.rand(2, 50, 50) > 0.5

            from modules.sam import save_masks_as_images

            save_masks_as_images(masks, temp_dir)

            # Verify files were created
            import os
            files = os.listdir(temp_dir)
            self.assertEqual(len(files), 2)
        finally:
            shutil.rmtree(temp_dir)


if __name__ == '__main__':
    unittest.main()
