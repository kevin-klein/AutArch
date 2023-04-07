import torchvision
import torch
import os
from PIL import Image
import transforms as T
from torchvision import datasets, models, transforms
import time
import torch.nn as nn
import utils
from torchvision.transforms.functional import rotate
from torchvision.io import read_image, ImageReadMode
import torch.nn as nn
import matplotlib.pyplot as plt
import torchvision.transforms.functional as F
import numpy as np
import random
from arrow_model import get_arrow_model

plt.rcParams["savefig.bbox"] = 'tight'

def get_transform():
   transforms = []
   # converts the image, a PIL image, into a PyTorch Tensor
   transforms.append(T.PILToTensor())
#    if train:
      # during training, randomly flip the training images
      # and ground-truth for data augmentation
    #   transforms.append(T.RandomHorizontalFlip(0.5))
   return T.Compose(transforms)

# https://github.com/d4nst/RotNet/blob/e026c0b1fa8a4a42eebce1d72261064d6147b939/utils.py
# def angle_error(baseline, predicted):


def show(imgs):
    # if not isinstance(imgs, list):
    #     imgs = [imgs]
    fig, axs = plt.subplots(ncols=len(imgs), squeeze=False)
    for i, img in enumerate(imgs):
        img = img[:3, :, :].detach()
        img = F.to_pil_image(img)
        axs[0, i].imshow(np.asarray(img))
        axs[0, i].set(xticklabels=[], yticklabels=[], xticks=[], yticks=[])
    plt.show()

if __name__ == '__main__':
  model = get_arrow_model()
  dataset = torchvision.datasets.ImageFolder('arrows', transforms.Compose([
        # transforms.RandomResizedCrop(224),
        # transforms.RandomHorizontalFlip(),
        transforms.ToTensor(),
        # transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
    ]))
  data_loader = torch.utils.data.DataLoader(
                dataset, pin_memory=True, batch_size=32, shuffle=True, num_workers=8,)

  device = torch.device('cuda')

  params = [p for p in model.parameters() if p.requires_grad]
  optimizer = torch.optim.SGD(params, lr=0.0001, momentum=0.9)
  # optimizer = torch.optim.Adam(params, lr=1e-4)
  weights = torchvision.models.ResNet18_Weights.DEFAULT
  criterion = nn.CrossEntropyLoss()

  num_epochs = 250
  for epoch in range(num_epochs):
      start = time.time()
      optimizer.zero_grad()

      model.train()

      i = 0
      epoch_loss = 0
      for images, targets in data_loader:
        # show(images)
        # images = [preprocess(image) for image in images]
        images = images.to(device)
        angles = [random.randint(0, 359) for _ in images]
        images = [rotate(image, angle, fill=1) for image, angle in zip(images, angles)]
        angles = torch.tensor([angle // 10 for angle in angles]).cuda()

        images = torch.stack(images).to(device)

        outputs = model(images)
        _, preds = torch.max(outputs, 1)
        # print('Predictions: ' + str(preds))
        # print('Angles: ' + str(angles))
        loss = criterion(outputs, angles)

        i += 1

        loss.backward()
        optimizer.step()

        epoch_loss += loss

      print(epoch_loss, f'time: {time.time() - start}')

  torch.save(model.state_dict(), 'models/arrow_resnet.model')
