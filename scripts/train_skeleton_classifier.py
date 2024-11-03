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

if __name__ == '__main__':
  dataset = torchvision.datasets.ImageFolder('training_data/skeletons', transforms.Compose([
        # transforms.RandomResizedCrop(224),
        transforms.Resize((300, 300)),
        transforms.RandomHorizontalFlip(),
        transforms.ToTensor(),
        # transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
    ]))
  data_loader = torch.utils.data.DataLoader(
                dataset, pin_memory=True, batch_size=12, shuffle=True, num_workers=8,)

  # model = torchvision.models.vit_b_16(weights=None, num_classes=2)
  # num_ftrs = model.fc.in_features
  # model.fc = nn.Linear(num_ftrs, 2).cuda()
  model = torchvision.models.resnet152(weights=None, num_classes=2)

  if torch.cuda.is_available():
      device = torch.device('cuda')
  else:
      device = torch.device('cpu')
  model.to(device)

  params = [p for p in model.parameters() if p.requires_grad]
  # optimizer = torch.optim.SGD(model.parameters(), lr=0.0001, momentum=0.9)
  # optimizer = torch.optim.AdamW(model.parameters(), lr=1e-4)
  optimizer = torch.optim.RMSprop(model.parameters(), lr=0.001)
  criterion = nn.CrossEntropyLoss()

  num_epochs = 400
  for epoch in range(num_epochs):
      start = time.time()
      optimizer.zero_grad()

      model.train()

      torch.save(dataset.classes, 'models/skeleton_resnet_labels.model')

      i = 0
      epoch_loss = 0
      for images, targets in data_loader:
        # show(images)
        # images = [preprocess(image) for image in images]
        # show(images)

        images = torch.tensor(images).to(device)
        targets = targets.to(device)

        outputs = model(images)
        # print(outputs)
        _, preds = torch.max(outputs, 1)
        loss = criterion(outputs, targets)

        i += 1

        loss.backward()
        optimizer.step()

        epoch_loss += loss

      torch.save(model.state_dict(), 'models/skeleton_resnet.model')

      print(epoch_loss, f'time: {time.time() - start}')
