import matplotlib.pyplot as plt
from torchvision.utils import draw_bounding_boxes, draw_segmentation_masks
from torchvision.io import read_image
import torch
from train_masks import get_model_instance_segmentation
import sys
import ml
device = torch.device('cuda') if torch.cuda.is_available() else torch.device('cpu')

labels = torch.load('models/maskrcnn_labels.model')
labels = {v: k for k, v in labels.items()}

model = get_model_instance_segmentation(len(labels.keys()), device)
result = ml.apply_mask(model, sys.argv[1])

image = read_image(sys.argv[1])

image = ml.get_transform(False)(image)

print(result['labels'])

pred_boxes = torch.stack([prediction for prediction in result['boxes']])
pred_labels = [labels[label.cpu().item()] for label in result['labels']]
masks = (result["masks"] > 0.7).squeeze(1)

print(masks.shape)

output_image = draw_bounding_boxes(image, pred_boxes, pred_labels, colors="red")

output_image = draw_segmentation_masks(output_image, masks, alpha=0.5, colors="blue")

plt.figure(figsize=(12, 12))
plt.imshow(output_image.permute(1, 2, 0))
plt.show()
