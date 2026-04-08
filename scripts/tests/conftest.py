"""
Pytest configuration and common fixtures for torch service tests.
"""

import pytest
import numpy as np
from PIL import Image
import io
import tempfile
import os


@pytest.fixture
def test_image():
    """Create a test image for testing."""
    # Create a simple colored image
    img = Image.new('RGB', (100, 100), color='blue')
    return img


@pytest.fixture
def test_image_bytes(test_image):
    """Create test image as bytes."""
    buffer = io.BytesIO()
    test_image.save(buffer, format='PNG')
    buffer.seek(0)
    return buffer.read()


@pytest.fixture
def numpy_test_image():
    """Create a numpy array test image."""
    return np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8)


@pytest.fixture
def mock_file(test_image_bytes):
    """Create a mock file object."""
    from unittest.mock import Mock
    mock_file = Mock()
    mock_file.file = io.BytesIO(test_image_bytes)
    mock_file.read = lambda: test_image_bytes
    return mock_file


@pytest.fixture
def temp_directory():
    """Create a temporary directory for testing."""
    with tempfile.TemporaryDirectory() as tmpdir:
        yield tmpdir


@pytest.fixture
def sample_image_paths(temp_directory):
    """Create sample image files for testing."""
    import cv2

    paths = []
    for i in range(3):
        img = np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8)
        path = os.path.join(temp_directory, f'image{i}.jpg')
        cv2.imwrite(path, img)
        paths.append(path)

    return paths


@pytest.fixture
def sample_points():
    """Create sample points for SAM testing."""
    return [[25, 25], [50, 50], [75, 75]]


@pytest.fixture
def sample_pattern_boxes():
    """Create sample pattern boxes."""
    return [[10, 10, 30, 30], [50, 50, 70, 70]]


@pytest.fixture
def mock_vocabulary():
    """Create a mock BOVW vocabulary."""
    from unittest.mock import Mock
    from sklearn.cluster import MiniBatchKMeans

    vocab = Mock(spec=MiniBatchKMeans)
    vocab.n_clusters = 32
    vocab.transform.return_value = np.random.rand(50, 32)
    return vocab


@pytest.fixture
def mock_sam_predictor():
    """Create a mock SAM predictor."""
    from unittest.mock import Mock
    import torch

    predictor = Mock()
    mock_masks = torch.rand(1, 100, 100)
    mock_scores = torch.tensor([0.95])
    predictor.predict.return_value = (mock_masks, mock_scores, None)
    return predictor


@pytest.fixture
def mock_detection_model():
    """Create a mock detection model."""
    from unittest.mock import Mock
    import torch

    model = Mock()
    mock_prediction = [{
        'boxes': torch.tensor([[10, 10, 100, 100]]),
        'scores': torch.tensor([0.95]),
        'labels': torch.tensor([0])
    }]
    model.return_value = mock_prediction
    return model


@pytest.fixture
def mock_arrow_model():
    """Create a mock arrow model."""
    from unittest.mock import Mock
    import torch

    model = Mock()
    mock_prediction = torch.tensor([[0.707, 0.707]])
    model.return_value = mock_prediction
    model.eval = Mock()
    return model


@pytest.fixture
def mock_skeleton_model():
    """Create a mock skeleton model."""
    from unittest.mock import Mock
    import torch

    model = Mock()
    mock_prediction = torch.tensor([[0.1, 0.8, 0.05, 0.05]])
    model.return_value = mock_prediction
    model.eval = Mock()
    return model


@pytest.fixture
def setup_test_environment():
    """Set up a complete test environment with mocked models."""
    from unittest.mock import patch, MagicMock
    import torch

    with patch('modules.models.registry') as mock_registry:
        # Setup detection model
        mock_detection = Mock()
        mock_prediction = [{
            'boxes': torch.tensor([[10, 10, 100, 100]]),
            'scores': torch.tensor([0.95]),
            'labels': torch.tensor([0])
        }]
        mock_detection.return_value = mock_prediction
        mock_registry.detection_model = mock_detection
        mock_registry.label2id = {0: 'Arrow', 1: 'Skeleton', 2: 'Grave'}

        # Setup SAM predictor
        mock_sam_predictor = Mock()
        mock_masks = torch.rand(1, 100, 100)
        mock_scores = torch.tensor([0.95])
        mock_sam_predictor.predict.return_value = (mock_masks, mock_scores, None)
        mock_registry.sam_predictor = mock_sam_predictor

        # Setup arrow model
        mock_arrow = Mock()
        mock_arrow.return_value = torch.tensor([[0.707, 0.707]])
        mock_arrow.eval = Mock()
        mock_registry.arrow_model = mock_arrow

        # Setup skeleton model
        mock_skeleton = Mock()
        mock_skeleton.return_value = torch.tensor([[0.1, 0.8, 0.05, 0.05]])
        mock_skeleton.eval = Mock()
        mock_registry.skeleton_model = mock_skeleton
        mock_registry.skeleton_labels = ['left', 'right', 'standing', 'unknown']

        mock_registry.device = torch.device('cpu')

        yield mock_registry


@pytest.fixture
def sample_efd_data():
    """Create sample EFD data."""
    return {
        'contour': [[10, 10], [20, 20], [30, 30], [40, 40], [50, 50]],
        'order': 15,
        'normalize': True,
        'return_transformation': False
    }


@pytest.fixture
def sample_bovw_data():
    """Create sample BOVW training data."""
    return {
        'images': ['image1.jpg', 'image2.jpg', 'image3.jpg'],
        'n_clusters': 32,
        'feature_type': 'sift'
    }


@pytest.fixture
def sample_pattern_match_data():
    """Create sample pattern matching data."""
    return {
        'query_image': 'query.jpg',
        'pattern_boxes': [[10, 10, 30, 30], [50, 50, 70, 70]],
        'target_images': ['target1.jpg', 'target2.jpg'],
        'feature_type': 'texture'
    }


def pytest_configure(config):
    """Configure pytest."""
    # Add custom markers
    config.addinivalue_line(
        "markers", "slow: marks tests as slow (deselect with '-m \"not slow\"')"
    )
    config.addinivalue_line(
        "markers", "integration: marks tests as integration tests"
    )
    config.addinivalue_line(
        "markers", "unit: marks tests as unit tests"
    )
