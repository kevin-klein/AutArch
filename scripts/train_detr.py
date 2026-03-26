import os
import xml.etree.ElementTree as ET
from PIL import Image
import numpy as np

import torch
from torch.utils.data import Dataset, DataLoader
from torch.amp import autocast, GradScaler

from transformers import AutoModelForObjectDetection, AutoImageProcessor
from torchmetrics.detection.mean_ap import MeanAveragePrecision

import albumentations as A
from tqdm import tqdm


DATA_ROOT = "training_data/object detection"
MODEL_SAVE_PATH = "models/rtdetr_fast"
MODEL_NAME = "PekingU/rtdetr_v2_r50vd"

BATCH_SIZE = 8
EPOCHS = 250
LR = 1e-4


# ---------------------------------------------------------
# XML cached dataset
# ---------------------------------------------------------

class CachedDataset(Dataset):

    def __init__(self, root, processor, transforms=None):

        self.root = root
        self.processor = processor
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

                boxes.append([xmin, ymin, xmax - xmin, ymax - ymin])
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

        img = np.array(Image.open(self.images[idx]).convert("RGB"))#.transpose(1, 0, 2)

        boxes = self.targets[idx]["boxes"]
        cats = self.targets[idx]["cats"]

        if self.transforms:
            t = self.transforms(image=img, bboxes=boxes, category=cats)

            img = t["image"]
            boxes = t["bboxes"]
            cats = t["category"]

        ann = {
            "image_id": idx,
            "annotations": [
                {
                    "bbox": b,
                    "category_id": c,
                    "area": b[2] * b[3],
                    "iscrowd": 0
                }
                for b, c in zip(boxes, cats)
            ]
        }

        enc = self.processor(images=img, annotations=ann, return_tensors="pt")

        return {
            "pixel_values": enc["pixel_values"].squeeze(),
            "labels": enc["labels"][0]
        }


# ---------------------------------------------------------
# collate
# ---------------------------------------------------------

def collate_fn(batch):

    return {
        "pixel_values": torch.stack([b["pixel_values"] for b in batch]),
        "labels": [b["labels"] for b in batch]
    }


# ---------------------------------------------------------
# training
# ---------------------------------------------------------

def train():

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

    processor = AutoImageProcessor.from_pretrained(MODEL_NAME)

    aug = A.Compose(
        [
            A.SmallestMaxSize(1000),
            # A.RandomSizedBBoxSafeCrop(600, 600),
            A.HorizontalFlip(p=0.5),
            A.RandomBrightnessContrast(p=0.5)
        ],
        bbox_params=A.BboxParams(format="coco", label_fields=["category"])
    )

    dataset = CachedDataset(DATA_ROOT, processor, aug)

    n = len(dataset)
    split = int(n * 0.8)

    train_ds, val_ds = torch.utils.data.random_split(
        dataset, [split, n - split])

    train_loader = DataLoader(
        train_ds,
        batch_size=BATCH_SIZE,
        shuffle=False,
        num_workers=1,
        persistent_workers=True,
        pin_memory=True,
        collate_fn=collate_fn
    )

    val_loader = DataLoader(
        val_ds,
        batch_size=BATCH_SIZE,
        shuffle=False,
        num_workers=1,
        persistent_workers=True,
        pin_memory=True,
        collate_fn=collate_fn
    )

    id2label = {v: k for k, v in dataset.labels.items()}
    label2id = dataset.labels

    model = AutoModelForObjectDetection.from_pretrained(
        MODEL_NAME,
        id2label=id2label,
        label2id=label2id,
        ignore_mismatched_sizes=True
    )

    model.to(device)

    optimizer = torch.optim.AdamW(model.parameters(), lr=LR)

    scaler = GradScaler('cuda')

    for epoch in range(EPOCHS):

        model.train()
        total_loss = 0

        for batch in tqdm(train_loader, desc='Training'):

            pixel_values = batch["pixel_values"].to(device)

            labels = [{k: v.to(device) for k, v in l.items()}
                      for l in batch["labels"]]

            with autocast('cuda'):

                outputs = model(pixel_values=pixel_values, labels=labels)

                loss = outputs.loss

            optimizer.zero_grad()

            scaler.scale(loss).backward()

            scaler.step(optimizer)

            scaler.update()

            total_loss += loss.item()

        print("train loss:", total_loss / len(train_loader))

        # ---------------- validation ----------------

        model.eval()

        valid_loss = 0

        with torch.no_grad():

            for batch in tqdm(val_loader, desc="Validation"):

                pixel_values = batch["pixel_values"].to(device)

                labels = [{k: v.to(device) for k, v in l.items()}
                      for l in batch["labels"]]

                outputs = model(pixel_values=pixel_values, labels=labels)

                loss = outputs.loss

                valid_loss += loss.item()

        print("valid loss:", valid_loss / len(val_loader))

    os.makedirs(MODEL_SAVE_PATH, exist_ok=True)

    model.save_pretrained(MODEL_SAVE_PATH)
    processor.save_pretrained(MODEL_SAVE_PATH)


if __name__ == "__main__":
    train()
