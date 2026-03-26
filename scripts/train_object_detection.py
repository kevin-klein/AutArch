import numpy as np
from torchvision.models.detection.backbone_utils import _resnet_fpn_extractor
from torchvision.ops.feature_pyramid_network import LastLevelP6P7
import torch
import torch.utils.data
from PIL import Image, ImageDraw
import torchvision
import time
import torchvision.transforms as TT
import os
import xml.etree.ElementTree as ET
import torchvision.transforms.functional as FT
from torchvision.models.detection.rpn import AnchorGenerator
from torchvision.models.detection import FasterRCNN_ResNet50_FPN_V2_Weights
from torchvision.models.detection.faster_rcnn import FasterRCNN_ResNet50_FPN_V2_Weights, FasterRCNN, FastRCNNConvFCHead, _default_anchorgen
from torchvision.models.detection.rpn import RPNHead
import torch.nn as nn
from torchvision import tv_tensors
from torchvision.transforms import v2
from torchvision.transforms import v2 as T

from tqdm import tqdm

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
    def __init__(self, root, transforms=None):

        self.root = root
        self.transforms = transforms

        xml_files = [f for f in os.listdir(root) if f.endswith(".xml") and os.path.exists(os.path.join(root, f).replace(".xml", ".jpg"))]

        self.images = []
        self.targets = []
        self.labels = {}

        label_counter = 0

        print("Caching XML annotations...")

        for xml_file in tqdm(xml_files):
            xml_path = os.path.join(root, xml_file)
            img_path = xml_path.replace(".xml", ".jpg")

            tree = ET.parse(xml_path)
            root_xml = tree.getroot()

            objects = root_xml.findall("object")

            boxes = []
            cats = []

            for obj in objects:

                name = obj.find("name").text

                if name not in self.labels:
                    self.labels[name] = label_counter
                    label_counter += 1

                label_id = self.labels[name]

                b = obj.find("bndbox")

                xmin = int(b.find("xmin").text)
                ymin = int(b.find("ymin").text)
                xmax = int(b.find("xmax").text)
                ymax = int(b.find("ymax").text)

                boxes.append([xmin, ymin, xmax, ymax])
                cats.append(label_id)

            self.images.append(img_path)

            self.targets.append({
                "boxes": boxes,
                "cats": cats
            })

        print("Classes:", self.labels)

    def __len__(self):
        return len(self.images)

    def __getitem__(self, idx):

        img = Image.open(self.images[idx]).convert("RGB")

        boxes = self.targets[idx]["boxes"]
        labels = self.targets[idx]["cats"]
        img = tv_tensors.Image(img)
        labels = torch.tensor(labels)
        boxes = tv_tensors.BoundingBoxes(boxes, format='XYXY', canvas_size=img.shape[-2:])

        if self.transforms:
            img, box_labels = self.transforms((img, {'boxes': boxes, 'labels': labels }))
            boxes = box_labels['boxes']
            labels = box_labels['labels']

        return img, {
            'boxes': boxes,
            'labels': labels,
            'path': self.images[idx]
        }

def collate_fn(batch):
    return tuple(zip(*batch))

def get_model(num_classes, device):
    backbone = torchvision.models.resnet50(weights=torchvision.models.ResNet50_Weights.IMAGENET1K_V2, progress=True)
    backbone = _resnet_fpn_extractor(backbone, 5, norm_layer=torch.nn.BatchNorm2d)

    rpn_anchor_generator = _default_anchorgen()
    rpn_head = RPNHead(backbone.out_channels, rpn_anchor_generator.num_anchors_per_location()[0], conv_depth=2)

    box_head = FastRCNNConvFCHead(
        (backbone.out_channels, 7, 7), [256, 256, 256, 256], [1024], norm_layer=nn.BatchNorm2d
    )

    model = FasterRCNN(
        backbone,
        num_classes=91,
        rpn_anchor_generator=rpn_anchor_generator,
        rpn_head=rpn_head,
        box_head=box_head,
    )
    model.load_state_dict(FasterRCNN_ResNet50_FPN_V2_Weights.DEFAULT.get_state_dict(progress=True, check_hash=True))

    # 3. Update the classifier head for your specific number of classes
    num_classes = num_classes  # e.g., 1 (Drawing) + 1 (Background)
    in_features = model.roi_heads.box_predictor.cls_score.in_features
    model.roi_heads.box_predictor = torchvision.models.detection.faster_rcnn.FastRCNNPredictor(
        in_features, num_classes
    )

    # anchor_sizes = ((32,), (64,), (128,), (256,), (512,))

    # aspect_ratios = ((0.2, 0.5, 1.0, 2.0, 5.0),) * len(anchor_sizes)

    # rpn_anchor_generator = AnchorGenerator(anchor_sizes, aspect_ratios)
    # rpn_head = RPNHead(backbone.out_channels, rpn_anchor_generator.num_anchors_per_location()[0], conv_depth=2)
    # model.rpn.head = rpn_head

    model.to(device)

    return model

def get_transforms(train=True):

    mean = [0.485, 0.456, 0.406]
    std  = [0.229, 0.224, 0.225]

    if train:
        transforms = T.Compose([
            T.ToDtype(torch.float32, scale=True),

            # random horizontal flip
            T.RandomHorizontalFlip(p=0.5),

            # scale jittering (multi-scale training)
            T.RandomShortestSize(
                min_size=[480, 512, 544, 576, 608, 640, 672, 704, 736, 768, 800],
                max_size=1000
            ),

            T.SanitizeBoundingBoxes(),

            T.Normalize(mean=mean, std=std),
        ])

    else:
        transforms = T.Compose([
            T.ToImage(),
            T.ToDtype(torch.float32, scale=True),

            # fixed inference size
            T.Resize(size=800, max_size=1000),

            T.SanitizeBoundingBoxes(),

            T.Normalize(mean=mean, std=std)
        ])

    return transforms

if __name__ == '__main__':
    torch.manual_seed(42)

    # create datasets with different transforms
    orig_train_dataset = DfgDataset(
        root="training_data/object detection",
        transforms=get_transforms(train=True)
    )

    test_dataset = DfgDataset(
        root="training_data/object detection",
        transforms=get_transforms(train=False)
    )

    # same random split indices for both datasets
    indices = torch.randperm(len(orig_train_dataset)).tolist()
    split = int(0.8 * len(indices))

    train_indices = indices[:split]
    test_indices = indices[split:]

    train_dataset = torch.utils.data.Subset(orig_train_dataset, train_indices)
    test_dataset  = torch.utils.data.Subset(test_dataset, test_indices)

    torch.save(orig_train_dataset.labels, "models/faster_rcnn_v2.model")

    data_loader = torch.utils.data.DataLoader(
                train_dataset, batch_size=4, shuffle=True, num_workers=6,
                collate_fn=collate_fn)
    data_loader_test = torch.utils.data.DataLoader(
                test_dataset, batch_size=4, shuffle=False, num_workers=6,
                collate_fn=collate_fn)
    print("We have: {} examples, {} are training and {} testing".format(len(indices), len(train_dataset), len(test_dataset)))

    if torch.cuda.is_available():
        device = torch.device('cuda')
    else:
        device = torch.device('cpu')

    num_classes = len(orig_train_dataset.labels.keys())
    model = get_model(num_classes, device)
    model.to(device)

    params = [p for p in model.parameters() if p.requires_grad]
    optimizer = torch.optim.Adam(params, lr=1e-4)

    scaler = torch.amp.GradScaler("cuda")

    num_epochs = 30
    for epoch in range(num_epochs):
        start = time.time()
        model.train()

        i = 0
        epoch_loss = 0
        valid_loss = 0
        for images, targets in tqdm(data_loader, desc='Training'):
            images = list(image.to(device) for image in images)
            targets = [{k: v.to(device) for k, v in [('boxes', t['boxes']), ('labels', t['labels'])]} for t in targets]


            with torch.autocast(device_type='cuda', dtype=torch.float16):
                loss_dict = model(images, targets)
                losses = sum(loss for loss in loss_dict.values())

            i += 1

            optimizer.zero_grad()
            losses.backward()
            optimizer.step()

            epoch_loss += losses

        # model.eval()
        with torch.no_grad():
            for images, targets in tqdm(data_loader_test, desc='Validation'):
                images = list(image.to(device) for image in images)
                targets = [{k: v.to(device) for k, v in [('boxes', t['boxes']), ('labels', t['labels'])]} for t in targets]

                loss_dict = model(images, targets)
                losses = sum(loss for loss in loss_dict.values())
                valid_loss += losses

        print(f'epoch: {epoch} epoch_loss: {epoch_loss}, validation_loss: {valid_loss}', f'time: {time.time() - start}')
        torch.save(model.state_dict(), 'models/fcos_resnext.model')
