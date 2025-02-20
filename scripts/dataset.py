import numpy as np
import torch
import torch.utils.data
from PIL import Image, ImageDraw
import torchvision
import time
import transforms as T
import torchvision.transforms as TT
import os
import xml.etree.ElementTree as ET
import torchvision.transforms.functional as FT

pil_transform = TT.ToPILImage()

name_map = {
    'skeleton_left_side': 'skeleton',
    'skeleton_right_side': 'skeleton',
    'arrow_left': 'arrow',
    'arrow_right': 'arrow',
    'arrow_up': 'arrow',
    'arrow_down': 'arrow',
    'skeleton_photo_left_side': 'skeleton_photo',
    'skeleton_photo_right_side': 'skeleton_photo',
    'compass_right': 'arrow',
    'compass_left': 'arrow',
    'compass_up': 'arrow',
    'compass_down': 'arrow',
    'grave_good': 'good',
    'stone': 'stone_tool',
    'skeletonm': 'skeleton'
}

class DfgDataset(torch.utils.data.Dataset):
    def __init__(self, root, transforms=None, labels={}):
        self.root = root
        self.transforms = transforms
        self.imgs = [x for x in sorted(os.listdir(root)) if x.endswith('.xml')]
        self.imgs = [os.path.join(self.root, img) for img in self.imgs]
        self.labels = labels
        # self.labels = torch.load('models/retinanet_labels_large.model')
        # self.labels = {v: k for k, v in self.labels.items()}
        self.counter = 0

        for xml_path in self.imgs:
            xml = ET.parse(xml_path)
            root = xml.getroot()

            objects = root.findall('object')
            labels = [object.find('name').text for object in objects]

            for name in labels:
                if name in name_map:
                    name = name_map[name]

                if name not in self.labels:
                    self.labels[name] = self.counter
                    self.counter += 1

    def get_label(self, name):
        if name in name_map:
            name = name_map[name]
        return self.labels[name]

    def __getitem__(self, idx):
        # load images and bounding boxes
        xml_path = self.imgs[idx]
        img_path = xml_path.replace('.xml', '.jpg').replace('ý', 'y').replace('š', 's')
        img = Image.open(img_path).convert("RGB")

        xml = ET.parse(xml_path)
        root = xml.getroot()

        objects = root.findall('object')
        labels = torch.tensor([self.get_label(object.find('name').text) for object in objects])
        bnd_boxes = [object.find('bndbox') for object in objects]

        boxes = torch.tensor([
            [
                int(box.find('xmin').text), #* x_factor,
                int(box.find('ymin').text), #* y_factor,
                int(box.find('xmax').text), #* x_factor,
                int(box.find('ymax').text) #* y_factor
            ]

                for box in bnd_boxes
            ])

        # dims = (512, 362)

        # new_image = FT.resize(img, dims)

        # old_dims = torch.FloatTensor([img.width, img.height, img.width, img.height]).unsqueeze(0)
        # new_boxes = boxes / old_dims

        # new_dims = torch.FloatTensor([dims[1], dims[0], dims[1], dims[0]]).unsqueeze(0)
        # new_boxes = new_boxes * new_dims

        return FT.to_tensor(img), {
            'boxes': boxes,
            'labels': labels,
        }

    def __len__(self):
        return len(self.imgs)

def collate_fn(batch):
    return tuple(zip(*batch))

def get_transform(train):
   transforms = []
   # converts the image, a PIL image, into a PyTorch Tensor
   transforms.append(T.PILToTensor())
#    if train:
      # during training, randomly flip the training images
      # and ground-truth for data augmentation
    #   transforms.append(T.RandomHorizontalFlip(0.5))
   return T.Compose(transforms)

dfg_dataset = DfgDataset(root="training_data/object detection", transforms = get_transform(train=True))

data_loader = torch.utils.data.DataLoader(
                dfg_dataset, batch_size=1, shuffle=True, num_workers=8,
                collate_fn=collate_fn)
