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

# device = torch.device('cuda') if torch.cuda.is_available() else torch.device('cpu')
# labels = torch.load('models/mask_rcnn_labels.model', map_location=device, weights_only=True)
# labels = {v: k for k, v in labels.items()}

object_detection_labels = torch.load('models/retinanet_v2_labels.model')
object_detection_labels = {v: k for k, v in object_detection_labels.items()}

def get_transform(train):
    transforms = []
    transforms.append(v2.ConvertBoundingBoxFormat(tv_tensors.BoundingBoxFormat.XYXY))
    transforms.append(v2.Resize(size=512))
    if train:
        transforms.append(v2.RandomHorizontalFlip(0.5))
    transforms.append(v2.ToDtype(torch.float, scale=True))
    transforms.append(v2.ToPureTensor())
    return v2.Compose(transforms)


def get_model_instance_segmentation():
    # load an instance segmentation model pre-trained on COCO
    backbone = torchvision.models.resnext50_32x4d(weights=torchvision.models.ResNeXt50_32X4D_Weights.DEFAULT)
    anchor_generator = AnchorGenerator(
        sizes=((32, 64, 128, 256, 512),),
        aspect_ratios=((0.5, 1.0, 2.0, 2.5, 3.0),)
    )
    backbone = _resnet_fpn_extractor(backbone, 5)

    model = torchvision.models.detection.MaskRCNN(backbone, num_classes=2, rpn_anchor_generator=anchor_generator)

    # get number of input features for the classifier
    in_features = model.roi_heads.box_predictor.cls_score.in_features
    # replace the pre-trained head with a new one
    model.roi_heads.box_predictor = FastRCNNPredictor(in_features, 2)

    # now get the number of input features for the mask classifier
    in_features_mask = model.roi_heads.mask_predictor.conv5_mask.in_channels
    hidden_layer = 256
    # and replace the mask predictor with a new one
    model.roi_heads.mask_predictor = MaskRCNNPredictor(
        in_features_mask,
        hidden_layer,
        2,
    )
    model.load_state_dict(torch.load('models/mask_rcnn_resnet50.model', map_location=device, weights_only=True))
    model.to(device)

    return model


def apply_mask(model, image_path):
    image = read_image(image_path)
    eval_transform = get_transform(train=False)

    model.eval()
    with torch.no_grad():
        x = eval_transform(image)
        # convert RGBA -> RGB and move to device
        # x = x[:3, ...].to(device)
        predictions = model([x.to(device), ])
        pred = predictions[0]
        # print(pred)

    masks = (pred["masks"] > 0.5).squeeze(1)
    print(pred['scores'])
    predictions = zip(pred["labels"], pred["scores"], pred["boxes"].long(), masks)
    predictions = [item for item in predictions if item[1] > 0.25]
    return predictions

def get_object_detection_model():
    num_classes = len(object_detection_labels.keys())
    model = torchvision.models.detection.retinanet_resnet50_fpn_v2(num_classes=num_classes)
    model.load_state_dict(torch.load('models/retinanet_v2_dfg.model', map_location=device))
    model.eval()
    model.to(device)

    return model

def apply_object_detection(model, image):
    with torch.no_grad():
        prediction = model([image.to(device)])

    result = []
    for element in range(len(prediction[0]["boxes"])):
        boxes = prediction[0]["boxes"][element].cpu().numpy().tolist()
        score = np.round(prediction[0]["scores"][element].cpu().numpy(), decimals= 4)

        label = labels[prediction[0]['labels'][element].cpu().item()]

        if score > 0.5:
            result.append({
                'score': score.tolist(),
                'box': boxes,
                'label': label
            })
    return result


get_object_detection_model()
