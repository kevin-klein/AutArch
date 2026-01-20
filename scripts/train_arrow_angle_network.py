import torchvision
import torch
import os
from torchvision import transforms
import time
import torch.nn as nn
from torchvision.transforms.functional import rotate
import torch.nn as nn
import random
import math

model = torchvision.models.convnext_tiny(weights=torchvision.models.ConvNeXt_Tiny_Weights.IMAGENET1K_V1)
model.classifier = nn.Sequential(
  nn.Flatten(),
  nn.Linear(768, 2)
)


if __name__ == '__main__':
  dataset = torchvision.datasets.ImageFolder('training_data/arrows', transforms.Compose([
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
    ]))
  data_loader = torch.utils.data.DataLoader(
                dataset, pin_memory=True, batch_size=16, shuffle=True, num_workers=8,)

  if torch.cuda.is_available():
      device = torch.device('cuda')
  else:
      device = torch.device('cpu')
  model.to(device)

  optimizer = torch.optim.AdamW(model.parameters(), lr=1e-4)
  criterion = nn.MSELoss()

  num_epochs = 250
  for epoch in range(num_epochs):
      start = time.time()
      optimizer.zero_grad()

      model.train()

      i = 0
      epoch_loss = 0
      for images, targets in data_loader:
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

  torch.save(model.state_dict(), 'models/arrow_convnext.model')
