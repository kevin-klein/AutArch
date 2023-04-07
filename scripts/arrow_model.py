import torchvision
import torch.nn as nn
import torch

def get_arrow_model():
  device = torch.device('cuda')
  model = torchvision.models.resnet18(pretrained=True)
  num_ftrs = model.fc.in_features
  model.fc = nn.Linear(num_ftrs, 36).cuda()
  model.load_state_dict(torch.load('models/arrow_resnet.model'))
  return model.to(device)
