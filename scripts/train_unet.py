import numpy as np
import torch
import torch.utils.data
from torchvision.transforms import v2
import os
from torchvision.io import decode_image
from torchvision.models.detection.backbone_utils import resnet_fpn_backbone
import utils
import torch.nn as nn
import torch.nn.functional as F
from torchvision import tv_tensors
import segmentation_models_pytorch as smp

device = torch.device('cuda')

class SegmentationDataset(torch.utils.data.Dataset):
  def __init__(self, root, transforms=None):
    self.root = root
    self.transforms = transforms
    self.mask_imgs = [x for x in sorted(os.listdir(root)) if x.endswith('.jpg') and 'mask' in x]
    self.mask_imgs = [os.path.join(self.root, img) for img in self.mask_imgs]
    self.counter = 1

  def __getitem__(self, idx):
    mask_image_path = self.mask_imgs[idx]
    image_path = mask_image_path.replace('_mask.', '.')

    image = decode_image(image_path)
    mask_image = decode_image(mask_image_path)

    mask = tv_tensors.Mask(mask_image)

    result = {
       'mask': mask
    }
    if self.transforms is not None:
      image, result = self.transforms(image, result)

    return image, result['mask']

  def __len__(self):
    return len(self.mask_imgs)

def get_transform(train):
    transforms = []
    transforms.append(v2.Resize(size=(512, 512)))
    if train:
        transforms.append(v2.RandomHorizontalFlip(0.5))
    transforms.append(v2.ToDtype(torch.float, scale=True))
    transforms.append(v2.ToPureTensor())
    return v2.Compose(transforms)

def train_one_epoch(model, optimizer, loss_fn, data_loader, device, epoch, scaler, print_freq=10):
  model.train()
  metric_logger = utils.MetricLogger(delimiter="  ")
  metric_logger.add_meter("lr", utils.SmoothedValue(window_size=1, fmt="{value:.6f}"))
  header = f"Epoch: [{epoch}]"

  lr_scheduler = None
  if epoch == 0:
      warmup_factor = 1.0 / 1000
      warmup_iters = min(1000, len(data_loader) - 1)

      lr_scheduler = torch.optim.lr_scheduler.LinearLR(
          optimizer, start_factor=warmup_factor, total_iters=warmup_iters
      )

  for images, targets in metric_logger.log_every(data_loader, print_freq, header):
      images = list(image.to(device) for image in images)
      targets = [t.to(device) for t in targets]
      with torch.amp.autocast("cuda", enabled=scaler is not None):
        out  = model(torch.stack(images, dim=0))

        loss = loss_fn(out, torch.stack(targets, dim=0))

      with torch.set_grad_enabled(True):
        # if scaler is not None:
            # scaler.scale(loss).backward()
            # scaler.step(optimizer)
            # scaler.update()
        # else:
          loss.backward()
          optimizer.step()
          optimizer.zero_grad()


      if lr_scheduler is not None:
          lr_scheduler.step()

      metric_logger.update(loss=loss,)
      metric_logger.update(lr=optimizer.param_groups[0]["lr"])

  return metric_logger

if __name__ == '__main__':
  # train on the GPU or on the CPU, if a GPU is not available
  device = torch.device('cuda') if torch.cuda.is_available() else torch.device('cpu')

  # our dataset has two classes only - background and person
  # use our dataset and defined transformations
  dataset = SegmentationDataset('/mnt/g/single_masks', get_transform(train=True))
  dataset_test = SegmentationDataset('/mnt/g/single_masks', get_transform(train=False))

  # split the dataset in train and test set
  indices = torch.randperm(len(dataset)).tolist()

  dataset, dataset_test = torch.utils.data.random_split(dataset, [0.8, 0.2])

  # define training and validation data loaders
  data_loader = torch.utils.data.DataLoader(
      dataset,
      batch_size=4,
      shuffle=True,
      collate_fn=utils.collate_fn
  )

  data_loader_test = torch.utils.data.DataLoader(
      dataset_test,
      batch_size=1,
      shuffle=False,
      collate_fn=utils.collate_fn
  )

  model = smp.Unet(
    encoder_name="efficientnet-b3",        # choose encoder, e.g. mobilenet_v2 or efficientnet-b7
    encoder_weights="imagenet",     # use `imagenet` pre-trained weights for encoder initialization
    in_channels=3,                  # model input channels (1 for gray-scale images, 3 for RGB, etc.)
    classes=1,                      # model output channels (number of classes in your dataset)
  )
  model.to(device)

  # construct an optimizer
  params = [p for p in model.parameters() if p.requires_grad]
  # optimizer = torch.optim.SGD(
  #     params,
  #     lr=0.005,
  #     momentum=0.9,
  #     weight_decay=0.0005
  # )

  optimizer = torch.optim.Adam(params, lr=2e-4)

  lr_scheduler = torch.optim.lr_scheduler.StepLR(
      optimizer,
      step_size=3,
      gamma=0.1
  )

  num_epochs = 15

  loss = smp.losses.DiceLoss(smp.losses.BINARY_MODE, from_logits=True)

  for epoch in range(num_epochs):
      # train for one epoch, printing every 10 iterations
      train_one_epoch(model, optimizer, loss, data_loader, device, epoch, lr_scheduler, print_freq=10)

      torch.save(model.state_dict(), 'models/unet.model')
      # update the learning rate
      lr_scheduler.step()
      # evaluate on the test dataset
      # evaluate(model, data_loader_test, device=device)

  print("That's it!")
