from train_masks import get_model_instance_segmentation, get_transform

# from torchvision.utils import draw_bounding_boxes, draw_segmentation_masks
  # import matplotlib.pyplot as plt

  # for images, targets in data_loader:
  #   image = images[0][0].repeat(3, 1, 1)

  #   print(targets[0]['boxes'])

  #   output_image = draw_bounding_boxes(image, targets[0]['boxes'], ['Grave' for _ in targets[0]['labels']], colors="red")

  #   masks = targets[0]['masks']
  #   output_image = draw_segmentation_masks(output_image, masks, alpha=0.5, colors="blue")

  #   plt.figure(figsize=(12, 12))
  #   plt.imshow(output_image.permute(1, 2, 0))
  #   plt.show()

