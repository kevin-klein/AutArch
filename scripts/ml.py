import torch
import torch.utils.data
import torchvision
from torchvision.transforms import v2
from torchvision import tv_tensors
from torchvision.models.detection.faster_rcnn import FastRCNNPredictor
from torchvision.models.detection.mask_rcnn import MaskRCNNPredictor
from torchvision.io import read_image
from torchvision.models.detection.rpn import AnchorGenerator
from torchvision.models.detection.backbone_utils import _resnet_fpn_extractor
import numpy as np
import torch.nn as nn
import torch.nn.functional as F

device = torch.device('cuda') if torch.cuda.is_available() else torch.device('cpu')
# device = torch.device('cpu')
# labels = torch.load('models/maskrcnn_labels.model', map_location=device, weights_only=True)
# labels = {v: k for k, v in labels.items()}

# object_detection_labels = torch.load('models/retinanet_v2_labels.model')
# object_detection_labels = {v: k for k, v in object_detection_labels.items()}



class DoubleConv(nn.Module):
    def __init__(self, in_channels, out_channels):
        super(DoubleConv, self).__init__()
        self.double_conv = nn.Sequential(
            nn.Conv2d(in_channels, out_channels, kernel_size=3, padding=1),
            nn.BatchNorm2d(out_channels),
            nn.ReLU(inplace=True),
            nn.Conv2d(out_channels, out_channels, kernel_size=3, padding=1),
            nn.BatchNorm2d(out_channels),
            nn.ReLU(inplace=True),
        )

    def forward(self, x):
        return self.double_conv(x)


class DownBlock(nn.Module):
    def __init__(self, in_channels, out_channels):
        super(DownBlock, self).__init__()
        self.double_conv = DoubleConv(in_channels, out_channels)
        self.down_sample = nn.MaxPool2d(2)

    def forward(self, x):
        skip_out = self.double_conv(x)
        down_out = self.down_sample(skip_out)
        return (down_out, skip_out)


class UpBlock(nn.Module):
    def __init__(self, in_channels, out_channels, up_sample_mode):
        super(UpBlock, self).__init__()
        if up_sample_mode == 'conv_transpose':
            self.up_sample = nn.ConvTranspose2d(in_channels-out_channels, in_channels-out_channels, kernel_size=2, stride=2)
        elif up_sample_mode == 'bilinear':
            self.up_sample = nn.Upsample(scale_factor=2, mode='bilinear', align_corners=True)
        else:
            raise ValueError("Unsupported `up_sample_mode` (can take one of `conv_transpose` or `bilinear`)")
        self.double_conv = DoubleConv(in_channels, out_channels)

    def forward(self, down_input, skip_input):
        x = self.up_sample(down_input)
        x = torch.cat([x, skip_input], dim=1)
        return self.double_conv(x)


class UNet(nn.Module):
    def __init__(self, out_classes=1, up_sample_mode='conv_transpose'):
        super(UNet, self).__init__()
        self.up_sample_mode = up_sample_mode
        # Downsampling Path
        self.down_conv1 = DownBlock(3, 64)
        self.down_conv2 = DownBlock(64, 128)
        self.down_conv3 = DownBlock(128, 256)
        self.down_conv4 = DownBlock(256, 512)
        # Bottleneck
        self.double_conv = DoubleConv(512, 1024)
        # Upsampling Path
        self.up_conv4 = UpBlock(512 + 1024, 512, self.up_sample_mode)
        self.up_conv3 = UpBlock(256 + 512, 256, self.up_sample_mode)
        self.up_conv2 = UpBlock(128 + 256, 128, self.up_sample_mode)
        self.up_conv1 = UpBlock(128 + 64, 64, self.up_sample_mode)
        # Final Convolution
        self.conv_last = nn.Conv2d(64, out_classes, kernel_size=1)

    def forward(self, x):
        x, skip1_out = self.down_conv1(x)
        x, skip2_out = self.down_conv2(x)
        x, skip3_out = self.down_conv3(x)
        x, skip4_out = self.down_conv4(x)
        x = self.double_conv(x)
        x = self.up_conv4(x, skip4_out)
        x = self.up_conv3(x, skip3_out)
        x = self.up_conv2(x, skip2_out)
        x = self.up_conv1(x, skip1_out)
        x = self.conv_last(x)
        return x

def get_transform(train):
    transforms = []
    transforms.append(v2.ConvertBoundingBoxFormat(tv_tensors.BoundingBoxFormat.XYXY))
    transforms.append(v2.Resize(size=(512, 512)))
    if train:
        transforms.append(v2.RandomHorizontalFlip(0.5))
    transforms.append(v2.ToDtype(torch.float, scale=True))
    transforms.append(v2.ToTensor())
    return v2.Compose(transforms)

def get_model_instance_segmentation(num_classes, device):
    # load an instance segmentation model pre-trained on COCO
    # backbone = resnet_fpn_backbone(backbone_name='resnet18', weights=torchvision.models.ResNet18_Weights.IMAGENET1K_V1, trainable_layers=5)

    # model = torchvision.models.detection.MaskRCNN(backbone, num_classes=2)

    model = torchvision.models.detection.maskrcnn_resnet50_fpn(weights=torchvision.models.detection.MaskRCNN_ResNet50_FPN_Weights.COCO_V1, trainable_backbone_layers=5)

    # get number of input features for the classifier
    in_features = model.roi_heads.box_predictor.cls_score.in_features
    # # replace the pre-trained head with a new one
    model.roi_heads.box_predictor = FastRCNNPredictor(in_features, num_classes=num_classes)

    # # now get the number of input features for the mask classifier
    in_features_mask = model.roi_heads.mask_predictor.conv5_mask.in_channels
    hidden_layer = 256
    # # and replace the mask predictor with a new one
    model.roi_heads.mask_predictor = MaskRCNNPredictor(
        in_features_mask,
        hidden_layer,
        2,
    )
    model.load_state_dict(torch.load('models/mask_rcnn_resnet50.model', map_location=device, weights_only=True))
    model.to(device)

    return model

def get_arrow_orientation_model():
    arrow_model = torchvision.models.resnet152(weights=torchvision.models.ResNet152_Weights.IMAGENET1K_V2)
    arrow_model.fc = torch.nn.Linear(in_features=2048, out_features=2, bias=True)
    arrow_model = arrow_model.to(device)

    arrow_model.load_state_dict(torch.load('models/arrow_resnet.model', map_location=device, weights_only=True))
    return arrow_model

def apply_arrow_orientation_model(model, image):
    image = torch.stack([v2.ToDtype(torch.float, scale=True)(image)]).to(device)
    with torch.no_grad():
        model.eval()
        result = model(image)
        return torch.atan2(result[0, 1], result[0, 0]).tolist()

def apply_mask(model, image_path):
    image = read_image(image_path)
    eval_transform = get_transform(train=False)

    model.eval()
    with torch.no_grad():
        x = eval_transform(image)
        # convert RGBA -> RGB and move to device
        x = x[:3, ...].to(device)
        predictions = model([x.to(device), ])
        pred = predictions[0]

    masks = (pred["masks"] > 0.5).squeeze(1)
    predictions = zip(pred["labels"], pred["scores"], pred["boxes"].long(), masks)
    predictions = [item for item in predictions] #if item[1] > 0.25]
    return predictions

def get_object_detection_model():
    num_classes = len(object_detection_labels.keys())
    model = torchvision.models.detection.retinanet_resnet50_fpn_v2(num_classes=num_classes)
    model.load_state_dict(torch.load('models/retinanet_v2_dfg.model', map_location=device, weights_only=True))
    model.eval()
    model.to(device)

    return model

def apply_object_detection(model, image):
    with torch.no_grad():
        image = get_transform(False)(image)
        prediction = model([image.to(device)])

    result = []
    for element in range(len(prediction[0]["boxes"])):
        boxes = prediction[0]["boxes"][element].cpu().numpy().tolist()
        score = np.round(prediction[0]["scores"][element].cpu().numpy(), decimals= 4)

        label = object_detection_labels[prediction[0]['labels'][element].cpu().item()]

        if score > 0.5:
            result.append({
                'score': score.tolist(),
                'box': boxes,
                'label': label
            })
    return result
