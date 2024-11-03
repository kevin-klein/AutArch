import torchvision
import torch
import os
from PIL import Image
import transforms as T
from torchvision import datasets, models, transforms
import time
import torch.nn as nn
from torchvision.transforms.functional import rotate
from torchvision.io import read_image, ImageReadMode
import torch.nn as nn
import matplotlib.pyplot as plt
import torchvision.transforms.functional as F
import numpy as np
import random
import math

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
  model = torchvision.models.resnet152(weights=torchvision.models.ResNet152_Weights.IMAGENET1K_V2)
  model.fc = torch.nn.Linear(in_features=2048, out_features=2, bias=True)

  dataset = torchvision.datasets.ImageFolder('skeleton_angles', transforms.Compose([
        # transforms.RandomResizedCrop(224),
        # transforms.RandomHorizontalFlip(),
        transforms.ToTensor(),
        # transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
    ]))
  data_loader = torch.utils.data.DataLoader(
                dataset, pin_memory=True, batch_size=16, shuffle=True, num_workers=8,)

  if torch.cuda.is_available():
        device = torch.device('cuda')
  else:
      device = torch.device('cpu')
  model.to(device)

  model.load_state_dict(torch.load('models/skeleton_orientation_resnet.model'))

  # optimizer = torch.optim.SGD(model.parameters(), lr=0.0001, momentum=0.9)
  optimizer = torch.optim.Adam(model.parameters(), lr=1e-5)
  # optimizer = torch.optim.RMSprop(model.parameters(), lr=0.001)
  # weights = torchvision.models.ResNet18_Weights.DEFAULT
  criterion = nn.MSELoss()

  # 3000
  num_epochs = 300
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
        angles = [random.randint(0, 360) for _ in images]
        images = [rotate(image, angle, fill=1) for image, angle in zip(images, angles)]
        angles = [[math.cos(math.radians(angle)), math.sin(math.radians(angle))] for angle in angles]
        angles = torch.tensor(angles).cuda()

        images = torch.stack(images).to(device)

        outputs = model(images)

        loss = criterion(outputs, angles)

        i += 1

        loss.backward()
        optimizer.step()

        epoch_loss += loss

      print(epoch_loss, f'time: {time.time() - start}')

      torch.save(model.state_dict(), 'models/skeleton_orientation_resnet.model')
