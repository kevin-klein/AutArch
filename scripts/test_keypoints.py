# apply_keypointrcnn.py
import os
from pathlib import Path
import torch
import torchvision
from torchvision.transforms import functional as F
from PIL import Image, ImageDraw
import numpy as np
from test_keypoints_custom import make_model

# --- Must match the training setup ---
KEYPOINT_NAMES = [
    "Head", "neck", "left shoulder", "right shoulder",
    "left elbow", "right elbow", "left wrist", "right wrist",
    "pelvic", "left hip", "right hip",
    "left knee", "right knee", "left ankle", "right ankle"
]
NUM_KEYPOINTS = len(KEYPOINT_NAMES)


def load_model(checkpoint_path, device):
    """Load model weights from a checkpoint."""
    model = make_model()
    checkpoint = torch.load(checkpoint_path, map_location=device)
    model.load_state_dict(checkpoint["model_state_dict"])
    model.to(device)
    model.eval()
    print(f"Loaded model from {checkpoint_path}")
    return model


def visualize_predictions(image, boxes, keypoints, scores, score_threshold=0.2):
    """Draw bounding boxes and keypoints on a PIL image."""
    if len(scores) == 0:
        return image

    i = np.argmax(scores)
    if scores[i] < score_threshold:
        return image

    max_box = boxes[i]
    draw = ImageDraw.Draw(image)


    # for i in range(len(boxes)):
    #     if scores[i] < score_threshold:
    #         continue
        # box = boxes[i].tolist()
        # draw.rectangle(box, outline="red", width=3)

    kps = keypoints[i].cpu().numpy()
    for j, (x, y, v) in enumerate(kps):
        if v > 0:  # visible or labeled
            r = 3
            draw.ellipse((x - r, y - r, x + r, y + r), fill="yellow")
            # optionally draw name
            name = KEYPOINT_NAMES[j]
            draw.text((x + 4, y - 4), name, fill="red")
    return image


def apply_model(model, image_folder, output_folder, device, score_threshold=0.2):
    """Run inference on all images in a folder and save visualizations."""
    os.makedirs(output_folder, exist_ok=True)
    image_paths = list(Path(image_folder).glob("*.[jp][pn]g"))  # jpg or png

    for img_path in image_paths:
        img = Image.open(img_path).convert("RGB")
        img = img.resize((256, 256))
        img_tensor = F.to_tensor(img).to(device)
        with torch.no_grad():
            prediction = model([img_tensor])[0]

        boxes = prediction["boxes"].cpu()
        scores = prediction["scores"].cpu()
        keypoints = prediction["keypoints"].cpu()

        vis_img = img.copy()
        vis_img = visualize_predictions(vis_img, boxes, keypoints, scores, score_threshold)

        out_path = Path(output_folder) / img_path.name
        vis_img.save(out_path)
        print(f"Saved: {out_path}")


def main():
    # ------------------- USER CONFIG -------------------
    CHECKPOINT_PATH = "checkpoints/keypointrcnn_resnet101.pth"
    IMAGE_FOLDER = "training_data/skeleton_keypoint_images"        # folder with input images
    OUTPUT_FOLDER = "predictions_out"   # where to save visualizations
    SCORE_THRESHOLD = 0.2               # ignore detections below this confidence
    # ---------------------------------------------------

    device = torch.device("cuda") if torch.cuda.is_available() else torch.device("cpu")
    model = load_model(CHECKPOINT_PATH, device)
    apply_model(model, IMAGE_FOLDER, OUTPUT_FOLDER, device, score_threshold=SCORE_THRESHOLD)


if __name__ == "__main__":
    main()
