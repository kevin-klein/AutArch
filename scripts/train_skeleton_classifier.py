import torchvision
import torch
import os
from PIL import Image
import transforms as T
from torchvision import datasets, models, transforms
import time
import torch.nn as nn
from torchvision.io import read_image, ImageReadMode
import torch.nn as nn
import matplotlib.pyplot as plt
import torchvision.transforms.functional as F
import numpy as np
from functools import partial
plt.rcParams["savefig.bbox"] = 'tight'

from torchvision.models.convnext import LayerNorm2d
norm_layer = partial(LayerNorm2d, eps=1e-6)

import torch.optim.lr_scheduler as lr_scheduler


def get_transform():
   transforms = []
   # converts the image, a PIL image, into a PyTorch Tensor
   transforms.append(T.PILToTensor())
#    if train:
      # during training, randomly flip the training images
      # and ground-truth for data augmentation
    #   transforms.append(T.RandomHorizontalFlip(0.5))
   return T.Compose(transforms)

# class torchvision.datasets.ImageFolder(torch.utils.data.Dataset):
#     def __init__(self, root, transforms=None, labels={}):
#         self.root = root
#         self.transforms = transforms

#         self.labels = []
#         self.images = []
#         for folder in os.listdir(root):
#           self.labels.append(folder)

#           for image in os.listdir(os.path.join(root, folder)):
#             self.images.append({
#               'image': image,
#               'label': folder,
#             })

#     def __getitem__(self, idx):
#         # load images and bounding boxes
#         image_data = self.images[idx]
#         img_path = os.path.join(self.root, image_data['label'], image_data['image'])
#         img = read_image(img_path, ImageReadMode.RGB)

#         return (torch.tensor(self.labels.index(image_data['label'])), img)


#     def __len__(self):
#         return len(self.images)

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

LR = 1e-5
EPOCHS = 100

if __name__ == '__main__':
  dataset = torchvision.datasets.ImageFolder('training_data/skeletons', transforms.Compose([
        # transforms.RandomResizedCrop(224),
        transforms.Resize((300, 300)),
        transforms.RandomHorizontalFlip(),
        transforms.ToTensor(),
        # transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
    ]))
  data_loader = torch.utils.data.DataLoader(
                dataset, pin_memory=True, batch_size=4, shuffle=True, num_workers=8,)

  model = torchvision.models.convnext_tiny(weights=torchvision.models.ConvNeXt_Tiny_Weights.IMAGENET1K_V1)
  model.classifier = nn.Sequential(
    model.classifier[0], model.classifier[1], nn.Linear(model.classifier[2].in_features, len(dataset.classes))
  )

  if torch.cuda.is_available():
      device = torch.device('cuda')
  else:
      device = torch.device('cpu')
  model.to(device)

  # params = [p for p in model.parameters() if p.requires_grad]
  # optimizer = torch.optim.SGD(model.parameters(), lr=0.0001, momentum=0.9)
  optimizer = torch.optim.Adam(model.parameters(), lr=LR)
  # optimizer = torch.optim.RMSprop(model.parameters(), lr=LR)
  criterion = nn.CrossEntropyLoss()

  scheduler = lr_scheduler.LinearLR(optimizer, start_factor=1, end_factor=0.01, total_iters=EPOCHS)

  torch.save(dataset.classes, 'models/skeleton_resnet_labels.model')
  model.train()

  for epoch in range(EPOCHS):
      start = time.time()

      i = 0
      epoch_loss = 0
      for images, targets in data_loader:
        # show(images)
        # images = [preprocess(image) for image in images]
        # show(images)

        images = images.to(device)
        targets = targets.to(device)

        outputs = model(images)
        loss = criterion(outputs, targets)

        i += 1

        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

        epoch_loss += loss

      scheduler.step()


      print(epoch_loss, f'time: {time.time() - start}')
  torch.save(model.state_dict(), 'models/skeleton_convnext_base.model')
