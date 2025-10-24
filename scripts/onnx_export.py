from scripts.train_object_detection import get_model
from transforms import PILToTensor, Compose
from PIL import Image, ImageDraw
import torch
import numpy as np
import os
import json

labels = torch.load('models/rcnn_labels_large.model')
labels = {v: k for k, v in labels.items()}

device = torch.device('cuda')

model = get_model(num_classes = len(labels.keys()))
model.load_state_dict(torch.load('models/rcnn_dfg_large.model'))
model.eval()
model.to(device)

device = torch.device('cuda')
image = Image.open('pdfs/page_images/129_168_Franculeasa, The children of the steppe.pdf-02.jpg')
img, _ = PILToTensor()(image)
# img = torch.randn(1, 3, 800, 1333)

torch.onnx.export(
    model,
    img[None, :].to(device),
    "co-move.onnx",
    verbose=True,
    input_names=["images_tensors"],
    output_names=["boxes", "labels", "scores"],
    dynamic_axes={"images_tensors": [0, 1, 2, 3], "boxes": [0, 1], "labels": [0],
                    "scores": [0]},
    export_params=True,
    # opset_version=12,
    # do_constant_folding=False,
)
with open('labels.json', 'w') as f:
    json.dump(labels, f)
