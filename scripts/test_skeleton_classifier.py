import torchvision
import torch
import os
from PIL import Image
import transforms as T
from torchvision import datasets, models, transforms
import time
import torch.nn as nn
from torchvision.io import read_image, ImageReadMode
from transforms import PILToTensor, Compose

print(torch.load('models/skeleton_resnet_labels.model'))

def pil_loader(path):
    # open path as file to avoid ResourceWarning (https://github.com/python-pillow/Pillow/issues/835)
    with open(path, "rb") as f:
        img = Image.open(f)
        return img.convert("RGB")

if __name__ == '__main__':
  if torch.cuda.is_available():
      device = torch.device('cuda')
  else:
      device = torch.device('cpu')

  model = torchvision.models.resnet152(pretrained=True)
  model.load_state_dict(torch.load('models/skeleton_resnet.model'))

  # model.eval()
  model.to(device)
  model.eval()

  with torch.no_grad():
    for image in os.listdir('skeletons/back'):
      print(image)
      image = pil_loader(os.path.join('skeletons', 'back', image))

      t = transforms.Compose([
          # transforms.RandomResizedCrop(224),
          # transforms.RandomHorizontalFlip(),
          transforms.ToTensor(),
          # transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
      ])
      image = torch.stack([t(image)]).to(device)
      print(image.size())
      # image = preprocess(image[:3, :, :]).unsqueeze(0).to(device)

      output = model(image)
      probabilities = torch.nn.functional.softmax(output[0], dim=0)
      top5, top5_id = torch.topk(probabilities, 2)
      print(probabilities)
