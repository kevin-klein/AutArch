"""
Model loading and initialization module.
"""

import torch
import torchvision
from mobile_sam import sam_model_registry, SamPredictor
from train_arrow_angle_network import model as arrow_model
from train_object_detection import get_model

# Device configuration
device = torch.device('cpu')


class ModelRegistry:
    """Central registry for all loaded models."""

    def __init__(self):
        self._models = {}
        self._labels = {}
        self._skeleton_labels = {}

    def initialize(self):
        """Initialize all models."""
        self._load_detection_model()
        self._load_sam_model()
        self._load_arrow_model()
        self._load_skeleton_model()

    def _load_detection_model(self):
        """Load object detection model."""
        self._labels = torch.load('models/faster_rcnn_v2.model')
        self._labels = {v: k for k, v in self._labels.items()}

        id2label = {v: k for k, v in self._labels.items()}
        label2id = self._labels

        loaded_model = get_model(num_classes=len(self._labels.keys()), device=device)
        loaded_model.load_state_dict(
            torch.load('models/rcnn_fpn.model', map_location=device)
        )
        loaded_model.eval()
        loaded_model.to(device)

        self._models['detection'] = loaded_model
        self._models['id2label'] = id2label
        self._models['label2id'] = label2id

    def _load_sam_model(self):
        """Load Segment Anything Model."""
        sam_checkpoint = "models/mobile_sam.pt"
        model_type = 'vit_t'

        sam = sam_model_registry[model_type](checkpoint=sam_checkpoint)
        sam.to(device=device)
        sam.eval()

        self._models['sam'] = sam
        self._models['sam_predictor'] = SamPredictor(sam)

    def _load_arrow_model(self):
        """Load arrow orientation model."""
        arrow_model.to(device)
        arrow_model.load_state_dict(
            torch.load('models/arrow_convnext.model', map_location=device, weights_only=True)
        )
        self._models['arrow'] = arrow_model

    def _load_skeleton_model(self):
        """Load skeleton classification model."""
        self._skeleton_labels = torch.load(
            'models/skeleton_resnet_labels.model', map_location=device
        )

        skeleton_model = torchvision.models.convnext_tiny(
            weights=None,
            num_classes=len(self._skeleton_labels)
        ).to(device)
        skeleton_model.load_state_dict(
            torch.load('models/skeleton_convnext_tiny.model', map_location=device)
        )

        self._models['skeleton'] = skeleton_model
        self._models['skeleton_labels'] = self._skeleton_labels

    @property
    def detection_model(self):
        return self._models['detection']

    @property
    def id2label(self):
        return self._models['id2label']

    @property
    def label2id(self):
        return self._models['label2id']

    @property
    def sam_predictor(self):
        return self._models['sam_predictor']

    @property
    def arrow_model(self):
        return self._models['arrow']

    @property
    def skeleton_model(self):
        return self._models['skeleton']

    @property
    def skeleton_labels(self):
        return self._models['skeleton_labels']


# Global registry instance
registry = ModelRegistry()
