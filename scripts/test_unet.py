from ml import UNet
from train_unet import get_transform
import torch
from torchvision.io import decode_image
import cv2
from torchvision.utils import save_image

device = torch.device('cuda')

model = UNet()
model.load_state_dict(torch.load('models/unet.model', map_location=device, weights_only=True))
model.to(device)

transform = get_transform(False)

image = transform(decode_image('/mnt/g/single_masks/86804.jpg'))
image = torch.stack([image], dim=0).to(device)

result = model(image)
threshold = (result.min() + result.max()) * 0.5
ima = torch.where(result > threshold, 0.9, 0.1)
save_image(ima, 'image.png')
