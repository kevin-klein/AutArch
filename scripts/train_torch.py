import numpy as np
import torch
import torch.utils.data
from PIL import Image, ImageDraw
import pandas as pd
# from torchvision.models.detection.faster_rcnn import FastRCNNPredictor
import torchvision
import sys
import time
import utils
import transforms as T
import os
import xml.etree.ElementTree as ET

name_map = {
    'skeleton_left_side': 'skeleton',
    'skeleton_right_side': 'skeleton',
    'arrow_left': 'arrow',
    'arrow_right': 'arrow',
    'arrow_up': 'arrow',
    'arrow_down': 'arrow',
    'skeleton_photo_left_side': 'skeleton_photo',
    'skeleton_photo_right_side': 'skeleton_photo',
    'compass_right': 'compass',
    'compass_left': 'compass',
    'compass_up': 'compass',
    'compass_down': 'compass'
}

class DfgDataset(torch.utils.data.Dataset):
    def __init__(self, root, transforms=None, labels={}):
        self.root = root
        self.transforms = transforms
        self.imgs = [x for x in sorted(os.listdir(root)) if x.endswith('.xml')]
        self.imgs = [os.path.join(self.root, img) for img in self.imgs]
        self.labels = labels
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
        img_path = xml_path.replace('.xml', '.jpg')
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

        target = {
            'boxes': boxes,
            'labels': labels,
        }

        if self.transforms is not None:
            img, target = self.transforms(img, target)

        return img, target

    def __len__(self):
        return len(self.imgs)

# dfg_dataset = DfgDataset(root="pdfs/page_images")
# img, target = dfg_dataset[0]
# # transform = T.ToPILImage()
# # img = transform(img)

# draw = ImageDraw.Draw(img)
# for box in target['boxes']:
#     draw.rectangle([(box[0], box[1]), (box[2], box[3])],
#         outline ="red", width =3)

# img.save('result.jpg')

# sys.exit(0)

def get_model(num_classes):
    # load an object detection model pre-trained on COCO
    # model = torchvision.models.detection.retinanet_resnet50_fpn_v2(num_classes=num_classes)
    model = torchvision.models.detection.fasterrcnn_resnet50_fpn_v2(num_classes=num_classes)
    # model = torchvision.models.detection.ssd300_vgg16(num_classes=num_classes)
    # get the number of input features for the classifier
    #    in_features = model.roi_heads.box_predictor.cls_score.in_features
    # replace the pre-trained head with a new on
    #    model.roi_heads.box_predictor = FastRCNNPredictor(in_features, num_classes)
    return model

def get_transform(train):
   transforms = []
   # converts the image, a PIL image, into a PyTorch Tensor
   transforms.append(T.PILToTensor())
#    if train:
      # during training, randomly flip the training images
      # and ground-truth for data augmentation
    #   transforms.append(T.RandomHorizontalFlip(0.5))
   return T.Compose(transforms)

if __name__ == '__main__':
    dfg_dataset = DfgDataset(root="pdfs/page_images", transforms = get_transform(train=True))
    dataset_test = DfgDataset(root="pdfs/page_images", transforms = get_transform(train=False), labels=dfg_dataset.labels)
    # split the dataset in train and test set

    print(dfg_dataset.labels)
    torch.manual_seed(1)
    indices = torch.randperm(len(dfg_dataset)).tolist()
    dataset = torch.utils.data.Subset(dfg_dataset, indices)
    dataset_test = torch.utils.data.Subset(dataset_test, indices[-30:])


    data_loader = torch.utils.data.DataLoader(
                dataset, batch_size=2, shuffle=True, num_workers=8,
                collate_fn=utils.collate_fn)
    data_loader_test = torch.utils.data.DataLoader(
            dataset_test, batch_size=1, shuffle=False, num_workers=8,
            collate_fn=utils.collate_fn)
    print("We have: {} examples, {} are training and {} testing".format(len(indices), len(dataset), len(dataset_test)))

    device = torch.device('cuda') # if torch.cuda.is_available() else torch.device('cpu')

    # our dataset has two classes only - raccoon and not racoon
    num_classes = len(dfg_dataset.labels.keys())
    # get the model using our helper function
    model = get_model(num_classes)
    # move model to the right device
    model.to(device)
    # construct an optimizer
    params = [p for p in model.parameters() if p.requires_grad]
    # optimizer = torch.optim.SGD(params, lr=0.0001,
    #                             momentum=0.9, weight_decay=0.0005)
    optimizer = torch.optim.Adam(params, lr=1e-4)

    num_epochs = 150
    for epoch in range(num_epochs):
        start = time.time()
        model.train()

        i = 0
        epoch_loss = 0
        for images, targets in data_loader:
            images = list(image.to(device) for image in images)
            targets = [{k: v.to(device) for k, v in t.items()} for t in targets]

            loss_dict = model(images, targets)
            losses = sum(loss for loss in loss_dict.values())

            i += 1

            optimizer.zero_grad()
            losses.backward()
            optimizer.step()

            epoch_loss += losses

        print(epoch_loss, f'time: {time.time() - start}')

    torch.save(model.state_dict(), 'models/ssd_dfg_large.model')
    torch.save(dfg_dataset.labels, 'models/ssd_labels_large.model')

# loss retinanet: 4.3512
# retinanet sgd lr=0.005 momentum=0.9 weight_decay=0.0005
# ssd adam lr=0.0001
# loss ssd: 4.136
# rcnn adam 0.0001
# loss rcnn: 6.4547
# retinanet large loss: 4.7259
