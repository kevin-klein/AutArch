import numpy as np
import torch
import torch.utils.data
import torchvision
from torchvision.transforms import v2
import os
import json
from torchvision.io import decode_image
from torchvision import tv_tensors
from torchvision.models.detection.faster_rcnn import FastRCNNPredictor
from torchvision.models.detection.mask_rcnn import MaskRCNNPredictor
from torchvision.models.detection.rpn import AnchorGenerator
from torchvision.models.detection.backbone_utils import resnet_fpn_backbone

class DfgDataset(torch.utils.data.Dataset):
  def __init__(self, root, transforms=None, labels={}):
    self.root = root
    self.transforms = transforms
    self.imgs = [x for x in sorted(os.listdir(root)) if x.endswith('.jpg') and 'mask' not in x]
    self.imgs = [os.path.join(self.root, img) for img in self.imgs]
    self.labels = labels
    # self.labels = torch.load('models/retinanet_labels_large.model')
    # self.labels = {v: k for k, v in self.labels.items()}
    self.counter = 1

    for image in self.imgs:
      with open(image.replace(".jpg", ".json"), "r") as f:
        annotation = json.load(f)
        labels = annotation["labels"]

        for name in labels:
          if name not in self.labels:
              self.labels[name] = self.counter
              self.counter += 1

  def get_label(self, name):
    return self.labels[name]


  def __getitem__(self, idx):
    # load images and bounding boxes
    image_path = self.imgs[idx]
    json_path = image_path.replace(".jpg", ".json")

    image = decode_image(image_path)

    with open(json_path, "r") as f:
      annotation = json.load(f)

    bnd_boxes = annotation["bounding_boxes"]
    labels = torch.tensor([1 for label in annotation["labels"]])

    bnd_boxes = tv_tensors.BoundingBoxes([
    [
      box["x"],
      box["y"],
      box["width"],
      box["height"]
    ] for box in bnd_boxes], format=tv_tensors.BoundingBoxFormat.XYWH, canvas_size=image.shape[-2:])

    masks = tv_tensors.Mask(torch.concat([tv_tensors.Mask(decode_image(os.path.join(self.root, mask_img)).to(torch.bool)) for mask_img in annotation["masks"]]))

    target = {
      'boxes': bnd_boxes,
      'labels': labels,
      'masks': masks
    }

    if self.transforms is not None:
      image, target = self.transforms(image, target)

    return image, target

  def __len__(self):
    return len(self.imgs)

def get_model_instance_segmentation(num_classes, device):
    # load an instance segmentation model pre-trained on COCO
    # backbone = resnet_fpn_backbone(backbone_name='resnet18', weights=torchvision.models.ResNet18_Weights.IMAGENET1K_V1, trainable_layers=5)

    # model = torchvision.models.detection.MaskRCNN(backbone, num_classes=2)

    model = torchvision.models.detection.maskrcnn_resnet50_fpn(weights=torchvision.models.detection.MaskRCNN_ResNet50_FPN_Weights.COCO_V1, trainable_backbone_layers=5)

    # get number of input features for the classifier
    in_features = model.roi_heads.box_predictor.cls_score.in_features
    # # replace the pre-trained head with a new one
    model.roi_heads.box_predictor = FastRCNNPredictor(in_features, num_classes + 1)

    # # now get the number of input features for the mask classifier
    in_features_mask = model.roi_heads.mask_predictor.conv5_mask.in_channels
    hidden_layer = 256
    # # and replace the mask predictor with a new one
    model.roi_heads.mask_predictor = MaskRCNNPredictor(
        in_features_mask,
        hidden_layer,
        2,
    )
    model.load_state_dict(torch.load('models/mask_rcnn_resnet50.model', map_location=device, weights_only=True))
    model.to(device)

    return model

def get_transform(train):
    transforms = []
    transforms.append(v2.ConvertBoundingBoxFormat(tv_tensors.BoundingBoxFormat.XYXY))
    transforms.append(v2.Resize(size=512))
    if train:
        transforms.append(v2.RandomHorizontalFlip(0.5))
    transforms.append(v2.ToDtype(torch.float, scale=True))
    transforms.append(v2.ToPureTensor())
    return v2.Compose(transforms)


from engine import train_one_epoch, evaluate
import utils

# train on the GPU or on the CPU, if a GPU is not available
device = torch.device('cuda') if torch.cuda.is_available() else torch.device('cpu')

# our dataset has two classes only - background and person
# use our dataset and defined transformations
dataset = DfgDataset('/mnt/g/masks', get_transform(train=True))
dataset_test = DfgDataset('/mnt/g/masks', get_transform(train=False))
num_classes = len(dataset.labels.keys())

torch.save(dataset.labels, 'models/maskrcnn_labels.model')

# split the dataset in train and test set
indices = torch.randperm(len(dataset)).tolist()

dataset, dataset_test = torch.utils.data.random_split(dataset, [0.8, 0.2])

# define training and validation data loaders
data_loader = torch.utils.data.DataLoader(
    dataset,
    batch_size=8,
    shuffle=True,
    collate_fn=utils.collate_fn
)

data_loader_test = torch.utils.data.DataLoader(
    dataset_test,
    batch_size=1,
    shuffle=False,
    collate_fn=utils.collate_fn
)

# get the model using our helper function
model = get_model_instance_segmentation(num_classes, device)

# move model to the right device
model.to(device)

# construct an optimizer
params = [p for p in model.parameters() if p.requires_grad]
optimizer = torch.optim.SGD(
    params,
    lr=0.005,
    momentum=0.9,
    weight_decay=0.0005
)
# and a learning rate scheduler
lr_scheduler = torch.optim.lr_scheduler.StepLR(
    optimizer,
    step_size=3,
    gamma=0.1
)

num_epochs = 15

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

for epoch in range(num_epochs):
    # train for one epoch, printing every 10 iterations
    train_one_epoch(model, optimizer, data_loader, device, epoch, print_freq=10)

    torch.save(model.state_dict(), 'models/mask_rcnn_resnet50.model')
    # update the learning rate
    lr_scheduler.step()
    # evaluate on the test dataset
    # evaluate(model, data_loader_test, device=device)

print("That's it!")
