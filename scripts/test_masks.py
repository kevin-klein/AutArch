import matplotlib.pyplot as plt
from torchvision.utils import draw_bounding_boxes, draw_segmentation_masks
from torchvision.io import read_image
import torch
import ml
import sys

model = ml.get_model_instance_segmentation(2, ml.device)
result = ml.apply_mask(model, sys.argv[1])

image = read_image(sys.argv[1])

image = ml.get_transform(False)(image)

pred_boxes = torch.stack([prediction[2] for prediction in result])
pred_labels = [ml.labels[label] for label in result['labels']]
masks = torch.stack([prediction[3] for prediction in result])

output_image = draw_bounding_boxes(image, pred_boxes, pred_labels, colors="red")

output_image = draw_segmentation_masks(output_image, masks, alpha=0.5, colors="blue")

plt.figure(figsize=(12, 12))
plt.imshow(output_image.permute(1, 2, 0))
plt.show()
