import torch
import torch.nn as nn
from torch.utils.data import DataLoader, Dataset
from transformers import AutoModelForObjectDetection, AutoImageProcessor, TrainingArguments, Trainer
from PIL import Image
import os
import xml.etree.ElementTree as ET
import torchvision.transforms.functional as FT
from tqdm import tqdm
import time
import numpy as np
from functools import partial
from transformers.image_transforms import center_to_corners_format, corners_to_center_format

def convert_bbox_yolo_to_pascal(boxes, image_size):

    """

    Convert bounding boxes from YOLO format (x_center, y_center, width, height) in range [0, 1]

    to Pascal VOC format (x_min, y_min, x_max, y_max) in absolute coordinates.

    Args:

        boxes (torch.Tensor): Bounding boxes in YOLO format

        image_size (tuple[int, int]): Image size in format (height, width)

    Returns:

        torch.Tensor: Bounding boxes in Pascal VOC format (x_min, y_min, x_max, y_max)

    """

    # convert center to corners format

    boxes = center_to_corners_format(boxes)

    # convert to absolute coordinates

    height, width = image_size

    boxes = boxes * torch.tensor([[width, height, width, height]])

    return boxes

# --- Configuration ---
# NOTE: The data root has been updated to your specified path.
DATA_ROOT = "training_data/object detection"
MODEL_SAVE_PATH = "models/conditional-detr-resnet"
PRETRAINED_MODEL_NAME = "microsoft/conditional-detr-resnet-50"

BATCH_SIZE = 8
LEARNING_RATE = 1e-4
NUM_EPOCHS = 10

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
    """
    Custom Dataset class for loading images and XML annotations.
    Modified to return PIL image instead of PyTorch Tensor
    to allow the RtDetrProcessor to handle resizing and normalization.
    """
    def __init__(self, root, transforms=None, labels={}):
        self.root = root
        self.transforms = transforms

        # Load files from the actual directory
        self.imgs = [x for x in sorted(os.listdir(root)) if x.endswith('.xml')]

        self.imgs = [os.path.join(self.root, img) for img in self.imgs]
        self.labels = labels
        self.counter = 0

        # XML Parsing and Label Collection
        print("Collecting labels...")
        for xml_path in self.imgs:
            try:
                # Mocking the XML content if using the mock path
                if 'mock' in xml_path:
                    labels = ['label_A', 'label_B']
                else:
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
            except FileNotFoundError:
                # This should only happen if the mock setup failed, or XML is missing in real data
                if root != "path/to/your/data":
                    print(f"Error: XML file not found at: {xml_path}. Skipping file for label collection.")
            except ET.ParseError:
                 print(f"Error parsing XML at: {xml_path}. Skipping file for label collection.")

        print(f"Found {len(self.labels)} unique classes: {self.labels}")

    def get_label(self, name):
        if name in name_map:
            name = name_map[name]
        return self.labels[name]


    def __getitem__(self, idx):
        xml_path = self.imgs[idx]

        # load images and bounding boxes
        img_path = xml_path.replace('.xml', '.jpg').replace('ý', 'y').replace('š', 's')
        img = Image.open(img_path).convert("RGB")

        xml = ET.parse(xml_path)
        root = xml.getroot()

        objects = root.findall('object')

        annotations = []
        for obj in objects:
            label_name = obj.find("name").text
            label_id = self.get_label(label_name)
            bbox = obj.find("bndbox")
            xmin = int(bbox.find("xmin").text)
            ymin = int(bbox.find("ymin").text)
            xmax = int(bbox.find("xmax").text)
            ymax = int(bbox.find("ymax").text)

            annotations.append({
                "bbox": torch.tensor([xmin, ymin, xmax - xmin, ymax - ymin]),  # (x, y, width, height)
                "category_id": label_id,
                "area": (xmax - xmin) * (ymax - ymin)
            })

        if self.transforms:
            img = self.transforms(img)

        # Convert image to tensor for the model
        # img_tensor = FT.to_tensor(img)

        target = {
            "image_id": torch.tensor(idx),
            "annotations": annotations
        }

        return img, target

    def __len__(self):
        return len(self.imgs)


# --- Collate Function for DataLoader ---

def collate_fn(batch):
    """
    Collates a batch of data using the RtDetrProcessor.
    The processor handles image padding, normalization, and bounding box conversion
    to the format required by the RT-DETR model (normalized cx, cy, w, h).
    """

    # Batch items are (PIL_Image, Target_Dict)
    images = [item[0] for item in batch]
    targets_from_dataset = [item[1] for item in batch]

    # The processor expects targets in the format:
    # [{'boxes': Tensor(pixel coords), 'class_labels': Tensor(indices)}, ...]
    targets = []
    for t in targets_from_dataset:
        targets.append(t)

    # Use the processor to transform the batch
    # This does: image resizing/padding/normalization and target conversion (pixel to normalized cx,cy,w,h)
    encoded_inputs = processor(images=images, annotations=targets, return_tensors="pt")

    return encoded_inputs

from dataclasses import dataclass

from torchmetrics.detection.mean_ap import MeanAveragePrecision


@dataclass
class ModelOutput:
    logits: torch.Tensor
    pred_boxes: torch.Tensor


# --- Main Training Function ---
@torch.no_grad()
def compute_metrics(evaluation_results, image_processor, threshold=0.0, id2label=None):

    """

    Compute mean average mAP, mAR and their variants for the object detection task.

    Args:

        evaluation_results (EvalPrediction): Predictions and targets from evaluation.

        threshold (float, optional): Threshold to filter predicted boxes by confidence. Defaults to 0.0.

        id2label (Optional[dict], optional): Mapping from class id to class name. Defaults to None.

    Returns:

        Mapping[str, float]: Metrics in a form of dictionary {<metric_name>: <metric_value>}

    """

    predictions, targets = evaluation_results.predictions, evaluation_results.label_ids

    # For metric computation we need to provide:

    #  - targets in a form of list of dictionaries with keys "boxes", "labels"

    #  - predictions in a form of list of dictionaries with keys "boxes", "scores", "labels"

    image_sizes = []

    post_processed_targets = []

    post_processed_predictions = []

    # Collect targets in the required format for metric computation

    for batch in targets:

        # collect image sizes, we will need them for predictions post processing

        batch_image_sizes = torch.tensor(np.array([x["orig_size"] for x in batch]))

        image_sizes.append(batch_image_sizes)

        # collect targets in the required format for metric computation

        # boxes were converted to YOLO format needed for model training

        # here we will convert them to Pascal VOC format (x_min, y_min, x_max, y_max)

        for image_target in batch:

            boxes = torch.tensor(image_target["boxes"])

            boxes = convert_bbox_yolo_to_pascal(boxes, image_target["orig_size"])

            labels = torch.tensor(image_target["class_labels"])

            post_processed_targets.append({"boxes": boxes, "labels": labels})

    # Collect predictions in the required format for metric computation,

    # model produce boxes in YOLO format, then image_processor convert them to Pascal VOC format

    for batch, target_sizes in zip(predictions, image_sizes):

        batch_logits, batch_boxes = batch[1], batch[2]

        output = ModelOutput(logits=torch.tensor(batch_logits), pred_boxes=torch.tensor(batch_boxes))

        post_processed_output = image_processor.post_process_object_detection(

            output, threshold=threshold, target_sizes=target_sizes

        )

        post_processed_predictions.extend(post_processed_output)

    # Compute metrics

    metric = MeanAveragePrecision(box_format="xyxy", class_metrics=True)

    metric.update(post_processed_predictions, post_processed_targets)

    metrics = metric.compute()

    # Replace list of per class metrics with separate metric for each class

    classes = metrics.pop("classes")

    map_per_class = metrics.pop("map_per_class")

    mar_100_per_class = metrics.pop("mar_100_per_class")

    for class_id, class_map, class_mar in zip(classes, map_per_class, mar_100_per_class):

        class_name = id2label[class_id.item()] if id2label is not None else class_id.item()

        metrics[f"map_{class_name}"] = class_map

        metrics[f"mar_100_{class_name}"] = class_mar

    metrics = {k: round(v.item(), 4) for k, v in metrics.items()}

    return metrics

def train_rtdetr():
    global id2label

    dataset = DfgDataset(root=DATA_ROOT)
    train_dataset, test_dataset = torch.utils.data.random_split(dataset, [0.8, 0.2])
    id2label = {v: k for k, v in dataset.labels.items()}
    label2id = dataset.labels
    num_labels = len(id2label)

    if num_labels == 0:
        print("Error: No labels found. Please ensure your DATA_ROOT contains valid XML files.")
        return

    # The processor needs the label maps to correctly handle the classes
    global processor
    processor = AutoImageProcessor.from_pretrained(
      PRETRAINED_MODEL_NAME,
      do_resize=True,
      do_pad=True,
    )

    model = AutoModelForObjectDetection.from_pretrained(
        PRETRAINED_MODEL_NAME,
        id2label=id2label,
        label2id=label2id,
        num_labels=num_labels,
        ignore_mismatched_sizes=True # Allow re-initialization of final layer
    )

    training_args = TrainingArguments(
      output_dir=MODEL_SAVE_PATH,
      num_train_epochs=500,
      fp16=True,
      per_device_train_batch_size=4,
      dataloader_num_workers=4,
      learning_rate=LEARNING_RATE,
      lr_scheduler_type="cosine",
      weight_decay=1e-4,
      max_grad_norm=0.01,
      metric_for_best_model="eval_map",
      greater_is_better=True,
      load_best_model_at_end=True,
      eval_strategy="epoch",
      save_strategy="epoch",
      save_total_limit=2,
      remove_unused_columns=False,
      eval_do_concat_batches=False,
      push_to_hub=False,
      torch_compile=False
    )

    eval_compute_metrics_fn = partial(
      compute_metrics, image_processor=processor, id2label=id2label, threshold=0.2
    )


    trainer = Trainer(
      model=model,
      args=training_args,
      train_dataset=train_dataset,
      eval_dataset=test_dataset,
      processing_class=processor,
      data_collator=collate_fn,
      compute_metrics=eval_compute_metrics_fn,
    )

    trainer.train()

    # Save the model
    os.makedirs(os.path.dirname(MODEL_SAVE_PATH), exist_ok=True)
    model.save_pretrained(MODEL_SAVE_PATH)

    # Save the processor (important for prediction/inference)
    processor.save_pretrained(MODEL_SAVE_PATH)

    print(f"\nTraining complete. Model and processor saved to: {MODEL_SAVE_PATH}")

if __name__ == "__main__":
    train_rtdetr()
