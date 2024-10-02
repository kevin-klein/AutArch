import torchvision
import torchvision.transforms.v2  as transforms
from torchvision.models.detection.keypoint_rcnn import KeypointRCNNPredictor
from torchvision.models.detection.rpn import AnchorGenerator
from torchvision.models.detection import keypointrcnn_resnet50_fpn
import os
import json
from cjm_torchvision_tfms.core import ResizeMax, PadSquare, CustomRandomIoUCrop, RandomPixelCopy
from torch.utils.data import Dataset, DataLoader
from PIL import Image
import multiprocessing

import torch

base_folder = '/home/kevin/KeypointAnnotate/export/'


def keypoints_to_bbox(keypoints, offset=10):
    """
    Convert a tensor of keypoint coordinates to a bounding box.

    Args:
    keypoints (Tensor): A tensor of shape (N, 2), where N is the number of keypoints.

    Returns:
    Tensor: A tensor representing the bounding box [xmin, ymin, xmax, ymax].
    """
    x_coordinates, y_coordinates = keypoints[:, :, 0], keypoints[:, :, 1]

    xmin = torch.min(x_coordinates)
    ymin = torch.min(y_coordinates)
    xmax = torch.max(x_coordinates)
    ymax = torch.max(y_coordinates)

    return [xmin-offset, ymin-offset, xmax+offset, ymax+offset]

def load_annotations(file):
    base_name = os.path.splitext(file)[0]
    annotations_file = os.path.join(base_folder, f"{base_name}.json")
    with open(annotations_file, 'r') as f:
        return json.load(f)

def list_all_classes(images):
    classes = set()
    for image in images:
        image_classes = [annotation['label'] for annotation in load_annotations(image)]
        classes.update(image_classes)

    return classes

class KeypointDataset(Dataset):
    def __init__(self, image_data, classes, transforms=None):
        super(Dataset, self).__init__()
        self.transforms = transforms
        self.image_data = image_data
        self.labels = list(classes)
        self.image_names = list(self.image_data.keys())

    def __len__(self):
        return len(self.image_data.keys())

    def __getitem__(self, index):
        image = Image.open(os.path.join(base_folder, self.image_names[index])).convert("RGB")
        image_tensor = transforms.ToTensor()(image)
        annotations = self.image_data[self.image_names[index]]

        keypoints = torch.Tensor([[[a['x'], a['y'], 1]] for a in annotations])
        box = keypoints_to_bbox(keypoints)
        target = {
            "boxes": torch.Tensor([box for a in annotations]),
            "keypoints": keypoints,
            "labels": torch.Tensor([self.labels.index(a['label']) for a in annotations]).to(torch.int64),
        }
        return image_tensor, target

images = filter(lambda x: x.endswith('.jpg'), os.listdir(base_folder))
images = list(images)

all_classes = list_all_classes(images)

image_data = {image: load_annotations(image) for image in images}


model = keypointrcnn_resnet50_fpn(weights=None, num_classes=len(all_classes), trainable_backbone_layers=5)

device = torch.device('cuda')
model.to(device)

train_sz = 300

iou_crop = CustomRandomIoUCrop(min_scale=0.3,
                               max_scale=1.0,
                               min_aspect_ratio=0.5,
                               max_aspect_ratio=2.0,
                               sampler_options=[0.0, 0.1, 0.3, 0.5, 0.7, 0.9, 1.0],
                               trials=400,
                               jitter_factor=0.25)

# Create a `ResizeMax` object
resize_max = ResizeMax(max_sz=train_sz)

# Create a `PadSquare` object
pad_square = PadSquare(shift=True)


data_aug_tfms = transforms.Compose(
    transforms=[
        transforms.ColorJitter(
                brightness = (0.8, 1.125),
                contrast = (0.5, 1.5),
                saturation = (0.5, 1.5),
                hue = (-0.05, 0.05),
        ),
        transforms.RandomGrayscale(),
        transforms.RandomEqualize(),
        RandomPixelCopy(max_pct=0.025),
        transforms.RandomPerspective(distortion_scale=0.15, p=0.5, fill=(123, 117, 104)),
        transforms.RandomRotation(degrees=90, fill=(123, 117, 104)),
        iou_crop,
    ],
)

# Compose transforms to resize and pad input images
resize_pad_tfm = transforms.Compose([
    resize_max,
    pad_square,
    transforms.Resize([train_sz] * 2, antialias=True)
])

# Compose transforms to sanitize bounding boxes and normalize input data
final_tfms = transforms.Compose([
    transforms.ToImage(),
    transforms.ToDtype(torch.float32, scale=True),
    transforms.SanitizeBoundingBoxes(),
])

# Define the transformations for training and validation datasets
train_tfms = transforms.Compose([
    data_aug_tfms,
    resize_pad_tfm,
    final_tfms
])
valid_tfms = transforms.Compose([resize_pad_tfm, final_tfms])

train_dataset = KeypointDataset(image_data, all_classes, train_tfms)
valid_dataset = KeypointDataset(image_data, all_classes, valid_tfms)

# print(train_dataset.__len__())
# print(train_dataset[0])

def run_epoch(model, dataloader, optimizer, device, epoch_id, is_training):
    """
    Function to run a single training or evaluation epoch.

    Args:
        model: A PyTorch model to train or evaluate.
        dataloader: A PyTorch DataLoader providing the data.
        optimizer: The optimizer to use for training the model.
        loss_func: The loss function used for training.
        device: The device (CPU or GPU) to run the model on.
        scaler: Gradient scaler for mixed-precision training.
        is_training: Boolean flag indicating whether the model is in training or evaluation mode.

    Returns:
        The average loss for the epoch.
    """
    # Set model to training mode
    model.train()

    # Initialize the average loss for the current epoch
    epoch_loss = 0

    # Iterate over data batches
    for batch_id, (inputs, targets) in enumerate(dataloader):
        targets = [{k: v.to(device) for k, v in t.items()} for t in targets]
        # Move inputs and targets to the specified device
        inputs = torch.stack(inputs).to(device)
        # Extract the ground truth bounding boxes and labels
        # gt_bboxes, gt_labels = zip(*[(d['boxes'].to(device), d['labels'].to(device)) for d in targets])

        # Convert ground truth bounding boxes from 'xyxy' to 'cxcywh' format and only keep center coordinates
        # gt_keypoints = torchvision.ops.box_convert(torch.stack(gt_bboxes), 'xyxy', 'cxcywh')[:,:,:2]

        # Initialize a visibility tensor with ones, indicating all keypoints are visible
        # visibility = torch.ones(len(inputs),gt_keypoints.shape[1],1).to(device)
        # Create a visibility mask based on whether the bounding boxes are valid (greater than or equal to 0)
        # visibility_mask = (torch.stack(gt_bboxes) >= 0.)[..., 0].view(visibility.shape).to(device)

        # Concatenate the keypoints with the visibility mask, adding a visibility channel to keypoints
        # gt_keypoints_with_visibility = torch.concat((
        #     gt_keypoints,
        #     visibility*visibility_mask
        # ), dim=2)

        # Convert keypoints to bounding boxes for each input and move them to the specified device
        # gt_object_bboxes = torch.vstack([keypoints_to_bbox(keypoints) for keypoints in gt_keypoints]).to(device)
        # # Initialize ground truth labels as tensor of ones and move them to the specified device
        # gt_labels = torch.ones(len(inputs), dtype=torch.int64).to(device)

        # Prepare the targets for the Keypoint R-CNN model
        # This includes bounding boxes, labels, and keypoints with visibility for each input image
        # keypoint_rcnn_targets = [
        #     {'boxes' : boxes[None], 'labels': labels[None], 'keypoints': keypoints[None]}
        #     for boxes, labels, keypoints in zip(gt_object_bboxes, gt_labels, gt_keypoints_with_visibility)
        # ]


        # Forward pass with Automatic Mixed Precision (AMP) context manager
        # with conditional_autocast(torch.device(device).type):
        if is_training:
            optimizer.zero_grad()

            loss_dict = model(inputs, targets)
            losses = sum(loss for loss in loss_dict.values())

            # losses = sum(loss for loss in loss_dict.values())
            # else:
                # with torch.no_grad():
                    # losses = model(inputs.to(device), move_data_to_device(keypoint_rcnn_targets, device))

            # Compute the loss
            # loss = sum([loss for loss in losses.values()])  # Sum up the losses

            losses.backward()
            optimizer.step()

            loss_item = losses.item()
            epoch_loss += loss_item

        # If loss is NaN or infinity, stop training
        if is_training:
            stop_training_message = f"Loss is NaN or infinite at epoch {epoch_id}, batch {batch_id}. Stopping training."
            # assert not math.isnan(loss_item) and math.isfinite(loss_item), stop_training_message

    return epoch_loss / (batch_id + 1)

def train_loop(model,
               train_dataloader,
               valid_dataloader,
               optimizer,
               device,
               epochs,
               checkpoint_path,
               use_scaler=False):
    """
    Main training loop.

    Args:
        model: A PyTorch model to train.
        train_dataloader: A PyTorch DataLoader providing the training data.
        valid_dataloader: A PyTorch DataLoader providing the validation data.
        optimizer: The optimizer to use for training the model.
        device: The device (CPU or GPU) to run the model on.
        epochs: The number of epochs to train for.
        checkpoint_path: The path where to save the best model checkpoint.
        use_scaler: Whether to scale graidents when using a CUDA device

    Returns:
        None
    """

    # Loop over the epochs
    for epoch in range(epochs):
        # Run a training epoch and get the training loss
        train_loss = run_epoch(model, train_dataloader, optimizer, device, epoch, is_training=True)
        # Run an evaluation epoch and get the validation loss
        # with torch.no_grad():
        #     valid_loss = run_epoch(model, valid_dataloader, None, device, epoch, is_training=False)

        print(train_loss)

        # # If the validation loss is lower than the best validation loss seen so far, save the model checkpoint
        # if valid_loss < best_loss:
        #     best_loss = valid_loss
        #     torch.save(model.state_dict(), checkpoint_path)

        #     # Save metadata about the training process
        #     training_metadata = {
        #         'epoch': epoch,
        #         'train_loss': train_loss,
        #         'valid_loss': valid_loss,
        #         'learning_rate': lr_scheduler.get_last_lr()[0],
        #         # 'model_architecture': model.name
        #     }
        #     with open('training_metadata.json', 'w') as f:
        #         json.dump(training_metadata, f)


# Set the training batch size
bs = 4

# Set the number of worker processes for loading data. This should be the number of CPUs available.
num_workers = multiprocessing.cpu_count()

# Define parameters for DataLoader
data_loader_params = {
    'batch_size': bs,  # Batch size for data loading
    'num_workers': num_workers,  # Number of subprocesses to use for data loading
    'persistent_workers': True,  # If True, the data loader will not shutdown the worker processes after a dataset has been consumed once. This allows to maintain the worker dataset instances alive.
    'pin_memory': True,  # If True, the data loader will copy Tensors into CUDA pinned memory before returning them. Useful when using GPU.
    # 'pin_memory_device': device,  # Specifies the device where the data should be loaded. Commonly set to use the GPU.
    'collate_fn': lambda batch: tuple(zip(*batch)),
}

# Create DataLoader for training data. Data is shuffled for every epoch.
train_dataloader = DataLoader(train_dataset, **data_loader_params, shuffle=True)

# Create DataLoader for validation data. Shuffling is not necessary for validation data.
valid_dataloader = DataLoader(valid_dataset, **data_loader_params)

# Learning rate for the model
lr = 5e-4

# Number of training epochs
epochs = 70

params = [p for p in model.parameters() if p.requires_grad]
optimizer = torch.optim.SGD(params, lr=lr, momentum=0.9, weight_decay=1e-4)

checkpoint_path = 'checkpoint.json'

train_loop(model=model,
           train_dataloader=train_dataloader,
           valid_dataloader=valid_dataloader,
           optimizer=optimizer,
           device=torch.device(device),
           epochs=epochs,
           checkpoint_path=checkpoint_path,
           use_scaler=True)
