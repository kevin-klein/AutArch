import torch

from test_keypoints import load_model

CHECKPOINT_PATH = "checkpoints/keypointrcnn_epoch20.pth"
device = torch.device("cuda") if torch.cuda.is_available() else torch.device("cpu")

# 1. Load the pre-trained Keypoint R-CNN model
print("Loading Keypoint R-CNN model...")
model = load_model(CHECKPOINT_PATH, device)
model.eval()

# 2. Define Dummy Input (needed for tracing)
x = torch.randn(1, 3, 224, 224).to(device)

# 3. Export
# Opset 11 or higher is required for R-CNN ops
print("Exporting to ONNX...")
torch.onnx.export(
    model,
    x,
    "models/keypoint_rcnn.onnx",
    opset_version=11,
    input_names=['input'],
    output_names=['boxes', 'labels', 'scores', 'keypoints'],
    dynamic_axes={
        'input': {0: 'batch', 2: 'height', 3: 'width'},
        'boxes': {0: 'detections'},
        'labels': {0: 'detections'},
        'scores': {0: 'detections'},
        'keypoints': {0: 'detections'}
    }
)
print("Saved keypoint_rcnn.onnx")
