# train_keypointrcnn.py
import json
import os
from pathlib import Path
from typing import List, Dict, Any

import torch
from torch.utils.data import Dataset, DataLoader
import torchvision
from torchvision.models.detection.backbone_utils import _resnet_fpn_extractor
from torchvision.models.detection.keypoint_rcnn import KeypointRCNN
from torchvision.transforms import functional as F
from torchvision.models import resnet101, ResNet101_Weights
from torch.optim.lr_scheduler import CosineAnnealingLR
from PIL import Image
import numpy as np

from torchvision.models import resnext50_32x4d, ResNeXt50_32X4D_Weights


# --- Edit this list if your dataset uses different keypoint labels ---
KEYPOINT_NAMES = [
    "Head", "neck", "left shoulder", "right shoulder",
    "left elbow", "right elbow", "left wrist", "right wrist",
    "pelvic", "left hip", "right hip",
    "left knee", "right knee", "left ankle", "right ankle"
]
NUM_KEYPOINTS = len(KEYPOINT_NAMES)
KP_NAME_TO_IDX = {n: i for i, n in enumerate(KEYPOINT_NAMES)}


def parse_labelstudio_json(json_path: str, image_dir: str):
    """
    Parse the JSON list (Label Studio export-like) into internal records.
    Returns a list of dicts: {'image_path': ..., 'width':w, 'height':h, 'persons': [ {keypoints: {name: (x,y)}}, ... ] }
    """
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    records = []
    for item in data:
        file_upload = item.get("file_upload", "")
        # rule: take the part after the first dash
        # example: '57b0015b-1.jpg' -> '1.jpg'
        if "-" in file_upload:
            filename = file_upload.split("-", 1)[1]
        else:
            filename = file_upload
        image_path = os.path.join(image_dir, filename)
        if not os.path.exists(image_path):
            print(f"WARNING: image not found: {image_path} (skipping)")
            continue

        width = None
        height = None
        persons = []

        annotations = item.get("annotations", []) or []
        for ann in annotations:
            result = ann.get("result", []) or []
            kp_dict = {}  # name -> (x_abs, y_abs)
            for r in result:
                typ = r.get("type", "")
                val = r.get("value", {})
                orig_w = r.get("original_width")
                orig_h = r.get("original_height")
                if orig_w is not None:
                    width = orig_w
                if orig_h is not None:
                    height = orig_h
                # assume x,y are percentages (0..100)
                x_pct = val.get("x")
                y_pct = val.get("y")
                labels = val.get("keypointlabels") or []
                if x_pct is None or y_pct is None or len(labels) == 0:
                    continue
                # there may be multiple labels but in your example it's single
                label = labels[0]
                # convert to absolute pixel coords
                if width is None or height is None:
                    # fall back to reading image size
                    with Image.open(image_path) as im:
                        w_img, h_img = im.size
                        width = w_img if width is None else width
                        height = h_img if height is None else height

                kp_dict[label] = (float(x_pct) / 100.0, float(y_pct) / 100.0)

            if kp_dict:
                persons.append(kp_dict)

        # fallback to real image size if not provided in annotations
        if width is None or height is None:
            with Image.open(image_path) as im:
                width, height = im.size

        records.append({
            "image_path": image_path,
            "width": int(width),
            "height": int(height),
            "persons": persons
        })
    return records


class KeypointDataset(Dataset):
    """
    PyTorch Dataset that returns images and targets suitable for torchvision.keypointrcnn.
    """

    def __init__(self, records: List[Dict[str, Any]], transforms=None, expand_bbox_factor: float = 0.1):
        """
        records: output from parse_labelstudio_json
        transforms: torchvision transforms to apply to the PIL image (and we'll apply same scaling to boxes/keypoints)
        expand_bbox_factor: fraction to pad bbox (e.g. 0.1 -> +10%)
        """
        self.records = records
        self.transforms = transforms
        self.expand_bbox_factor = expand_bbox_factor

    def __len__(self):
        return len(self.records)

    def _person_to_target(self, person_kp_dict, img_w, img_h):
        """
        Given a dict mapping keypoint name -> (x,y) produce:
            - keypoints array shape (K,3): x,y,v
            - bbox [x_min, y_min, x_max, y_max]
        """
        keypoints = np.zeros((NUM_KEYPOINTS, 3), dtype=np.float32)
        present = []
        for name, idx in KP_NAME_TO_IDX.items():
            if name in person_kp_dict:
                x, y = person_kp_dict[name]
                keypoints[idx, 0] = float(x) * img_w
                keypoints[idx, 1] = float(y) * img_h
                keypoints[idx, 2] = 2.0  # visible & labeled
                present.append((x, y))
            else:
                # leave as zeros and v=0 -> not labeled
                keypoints[idx, 2] = 0.0

        if len(present) == 0:
            # fallback tiny bbox at image center
            cx, cy = img_w / 2.0, img_h / 2.0
            bbox = [cx - 1.0, cy - 1.0, cx + 1.0, cy + 1.0]
        else:
            xs = [p[0] for p in present]
            ys = [p[1] for p in present]
            x_min = float(min(xs))
            x_max = float(max(xs))
            y_min = float(min(ys))
            y_max = float(max(ys))
            w = x_max - x_min
            h = y_max - y_min
            pad = max(w, h) * self.expand_bbox_factor
            x_min = max(0.0, x_min - pad)
            y_min = max(0.0, y_min - pad)
            x_max = min(float(img_w), x_max + pad)
            y_max = min(float(img_h), y_max + pad)
            bbox = [x_min, y_min, x_max, y_max]

        area = (bbox[2] - bbox[0]) * (bbox[3] - bbox[1])
        return keypoints, bbox, area

    def __getitem__(self, idx):
        rec = self.records[idx]
        img_path = rec["image_path"]
        img = Image.open(img_path).convert("RGB")
        img = img.resize((256, 256))
        img_w, img_h = img.size

        target = {}
        persons = rec.get("persons", [])
        boxes = []
        labels = []
        keypoints_list = []
        areas = []
        iscrowd = []

        for person in persons:
            kps, bbox, area = self._person_to_target(person, img_w, img_h)
            boxes.append(bbox)
            labels.append(1)  # single class "person" -> label 1
            keypoints_list.append(kps)
            areas.append(area)
            iscrowd.append(0)

        if len(boxes) == 0:
            # empty targets allowed (list -> tensors with 0 rows)
            target["boxes"] = torch.zeros((0, 4), dtype=torch.float32)
            target["labels"] = torch.zeros((0,), dtype=torch.int64)
            target["keypoints"] = torch.zeros((0, NUM_KEYPOINTS, 3), dtype=torch.float32)
            target["area"] = torch.zeros((0,), dtype=torch.float32)
            target["iscrowd"] = torch.zeros((0,), dtype=torch.int64)
            target["image_id"] = torch.tensor([idx])
        else:
            boxes = torch.as_tensor(boxes, dtype=torch.float32)
            labels = torch.as_tensor(labels, dtype=torch.int64)
            keypoints = torch.as_tensor(np.array(keypoints_list), dtype=torch.float32)
            areas = torch.as_tensor(areas, dtype=torch.float32)
            iscrowd = torch.as_tensor(iscrowd, dtype=torch.int64)
            target["boxes"] = boxes
            target["labels"] = labels
            target["keypoints"] = keypoints
            target["area"] = areas
            target["iscrowd"] = iscrowd
            target["image_id"] = torch.tensor([idx])

        if self.transforms:
            img = self.transforms(img)

        return img, target


def collate_fn(batch):
    return tuple(zip(*batch))


def make_model(num_keypoints=NUM_KEYPOINTS, num_classes=2):  # 1 class (person) + background
    """
    Create a keypointrcnn model. num_classes include background.
    """
    backbone = resnext50_32x4d(weights=ResNeXt50_32X4D_Weights.IMAGENET1K_V2)
    backbone = _resnet_fpn_extractor(backbone, 5, norm_layer=torch.nn.BatchNorm2d)
    model = KeypointRCNN(backbone, num_classes, num_keypoints=num_keypoints)

    # Replace the box predictor for number of classes
    in_features = model.roi_heads.box_predictor.cls_score.in_features
    model.roi_heads.box_predictor = torchvision.models.detection.faster_rcnn.FastRCNNPredictor(in_features, num_classes)
    # Replace keypoint predictor
    in_features_kp = model.roi_heads.keypoint_predictor.kps_score_lowres.in_channels
    # torchvision provides a helper:
    model.roi_heads.keypoint_predictor = torchvision.models.detection.keypoint_rcnn.KeypointRCNNPredictor(
        in_features_kp, num_keypoints
    )
    return model


def train_one_epoch(model, optimizer, data_loader, device, stepper):
    model.train()
    running_loss = 0.0
    for images, targets in data_loader:
        images = list(img.to(device) for img in images)
        targets = [{k: v.to(device) for k, v in t.items()} for t in targets]
        loss_dict = model(images, targets)
        losses = sum(loss for loss in loss_dict.values())

        optimizer.zero_grad()
        losses.backward()
        optimizer.step()
        stepper.step()

        running_loss += losses.item()
    return running_loss / len(data_loader)


def main(
    JSON_PATH,
    IMAGE_DIR,
    output_dir="checkpoints",
    batch_size=4,
    num_epochs=10,
    lr=1e-5,
    weight_decay=1e-4,
    num_workers=4
):
    records = parse_labelstudio_json(JSON_PATH, IMAGE_DIR)
    print(f"Loaded {len(records)} records")

    # basic transform: ToTensor (also normalizes to [0,1])
    def _transforms(img: Image.Image):
        return F.to_tensor(img)

    dataset = KeypointDataset(records, transforms=_transforms)
    data_loader = DataLoader(dataset, batch_size=batch_size, shuffle=True, num_workers=num_workers,
                             collate_fn=collate_fn)

    device = torch.device("cuda") if torch.cuda.is_available() else torch.device("cpu")
    print("Using device:", device)

    model = make_model(num_keypoints=NUM_KEYPOINTS, num_classes=2)
    model.to(device)

    params = [p for p in model.parameters() if p.requires_grad]
    optimizer = torch.optim.AdamW(params, lr=lr, weight_decay=weight_decay)
    scheduler = CosineAnnealingLR(optimizer, T_max=num_epochs)

    os.makedirs(output_dir, exist_ok=True)

    for epoch in range(1, num_epochs + 1):
        loss = train_one_epoch(model, optimizer, data_loader, device, scheduler)
        print(f"Epoch {epoch}/{num_epochs}  loss: {loss:.4f}")

    # save checkpoint
    ckpt_path = os.path.join(output_dir, f"keypointrcnn_resnet101.pth")
    torch.save({
        "epoch": epoch,
        "model_state_dict": model.state_dict(),
        "optimizer_state_dict": optimizer.state_dict(),
    }, ckpt_path)
    print(f"Saved checkpoint: {ckpt_path}")


if __name__ == "__main__":
    # ------------------- USER CONFIG -------------------
    # path to JSON file (Label Studio export-like list of items)
    JSON_PATH = "training_data/Keynote Skeletons.json"
    # directory containing images; filenames are derived by taking part after the first '-' in file_upload
    IMAGE_DIR = "training_data/skeleton_keypoint_images"
    # ---------------------------------------------------
    main(JSON_PATH, IMAGE_DIR, output_dir="checkpoints", batch_size=4, num_epochs=500)
