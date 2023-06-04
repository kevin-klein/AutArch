import torchvision
import torch.nn as nn
import torch
import torch.nn.functional as F

def get_arrow_model():
  device = torch.device('cuda')
  model = torchvision.models.efficientnet_v2_l(weights=None, num_classes=360)
  # model = torchvision.models.vit_b_32(num_classes=36, weights=None)
  # model = RotNet(nb_classes=360)
  # num_ftrs = model.fc.in_features
  # model.fc = nn.Linear(num_ftrs, 36).cuda()
  # model.load_state_dict(torch.load('models/arrow_resnet.model'))
  return model.to(device)

class RotNet(nn.Module):

  def __init__(self, nb_classes, nb_filters=64):
    super().__init__()
    self.conv1 = nn.Conv2d(3, 64, kernel_size=3)
    self.conv2 = nn.Conv2d(64, 64, kernel_size=3)
    self.max_pool = nn.MaxPool2d((2, 2))
    self.dropout1 = nn.Dropout(p=0.25)
    self.flatten = nn.Flatten()
    self.dense1 = nn.Linear(774400, 128)
    self.dropout2 = nn.Dropout(p=0.25)
    self.dense2 = nn.Linear(128, nb_classes)
    self.softmax = nn.Softmax(dim=1)

  def forward(self, x):
    x = F.relu(self.conv1(x))
    x = F.relu(self.conv2(x))
    x = self.max_pool(x)
    x = self.dropout1(x)
    x = self.flatten(x)
    x = F.relu(self.dense1(x))
    x = self.dropout2(x)
    x = F.softmax(self.dense2(x))
    # x = self.softmax(x)
    # print(x)
    return x

