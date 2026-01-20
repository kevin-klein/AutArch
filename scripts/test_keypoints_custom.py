# apply_keypointrcnn.py
import os
from pathlib import Path
import torch
import torchvision
from torchvision.transforms import functional as F
from PIL import Image, ImageDraw
import numpy as np
from scipy.spatial import procrustes
from sklearn.decomposition import PCA
from sklearn.manifold import TSNE
from sklearn.cluster import KMeans
import matplotlib.pyplot as plt
from train_keypoint_custom import make_model

# --- Must match the training setup ---
KEYPOINT_NAMES = [
    "Head", "neck", "left shoulder", "right shoulder",
    "left elbow", "right elbow", "left wrist", "right wrist",
    "pelvic", "left hip", "right hip",
    "left knee", "right knee", "left ankle", "right ankle"
]
NUM_KEYPOINTS = len(KEYPOINT_NAMES)

def align_poses(keypoints, reference=None):
    """
    Align poses using Procrustes analysis to make them rotation-invariant
    Returns aligned keypoints and the transformation parameters
    """
    if reference is None:
        # Use the first pose as reference
        reference = keypoints[0]

    aligned_poses = []
    transformations = []

    for pose in keypoints:
        # Perform Procrustes analysis
        mtx1, mtx2, disparity = procrustes(reference, pose)

        # Store the aligned pose
        aligned_poses.append(mtx2)

        # Store the transformation (rotation matrix)
        transformations.append(mtx1)

    return np.array(aligned_poses)


def load_model(checkpoint_path, device):
    """Load model weights from a checkpoint."""
    model = make_model()
    checkpoint = torch.load(checkpoint_path, map_location=device)
    model.load_state_dict(checkpoint["model_state_dict"])
    model.to(device)
    model.eval()
    print(f"Loaded model from {checkpoint_path}")
    return model


def visualize_predictions(image, boxes, keypoints, scores, score_threshold=0.5):
    """Draw bounding boxes and keypoints on a PIL image."""
    draw = ImageDraw.Draw(image)
    # Find the best scoring box
    if scores.shape[0] == 0:
        return

    best_idx = torch.argmax(scores)
    if scores[best_idx] < score_threshold:
        return image  # Skip if best score is below threshold
    kps = keypoints[best_idx].cpu().numpy()
    for j, (x, y, v) in enumerate(kps):
        if v > 0.6:  # visible or labeled and confidence > 0.6
            r = 3
            draw.ellipse((x - r, y - r, x + r, y + r), fill="yellow")
            # optionally draw name
            name = KEYPOINT_NAMES[j]
            draw.text((x + 4, y - 4), name, fill="red")
    return image


def apply_model(model, image_folder, output_folder, device, score_threshold=0.5):
    """Run inference on all images in a folder and save visualizations."""
    os.makedirs(output_folder, exist_ok=True)
    image_paths = list(Path(image_folder).glob("*.[jp][pn]g"))  # jpg or png
    poses = []

    for img_path in image_paths:
        img = Image.open(img_path).convert("RGB")
        img_tensor = F.to_tensor(img).to(device)
        with torch.no_grad():
            prediction = model([img_tensor])[0]

        boxes = prediction["boxes"].cpu()
        scores = prediction["scores"].cpu()
        keypoints = prediction["keypoints"].cpu()

        if scores.shape[0] == 0:
            continue
        best_idx = torch.argmax(scores)
        if scores[best_idx] < score_threshold:
            continue

        kps = keypoints[best_idx].cpu().numpy().tolist()
        poses.append(np.array([[x, y] for [x, y, v] in kps]))

    poses = align_poses(poses)

    # print(poses)
    X = np.array([pose.flatten() for pose in poses])
    pca = PCA(n_components=2)
    tsne = TSNE(n_components=2)
    X_pca = pca.fit_transform(X)
    X_tsne = tsne.fit_transform(X)

    # Cluster in reduced space
    # kmeans = KMeans(n_clusters=5, random_state=42)
    # labels = kmeans.fit_predict(X_pca)

    # plt.figure(figsize=(12, 8))
    # for i, (pose, label) in enumerate(zip(poses, labels)):
        # plt.scatter(pose[:,0], pose[:,1], label=f'Pose {i+1} - Cluster {label}')

    fig, (ax1, ax2) = plt.subplots(1, 2)
    fig.suptitle("Skeleton Poses")
    ax1.scatter(X_pca[:, 0], X_pca[:, 1])
    ax2.scatter(X_tsne[:, 0], X_tsne[:, 1])

    ax1.set_title("PCA")
    ax2.set_title("TSNE")
    plt.savefig("skeleton poses.png")

    # plt.show()

def main():
    # ------------------- USER CONFIG -------------------
    CHECKPOINT_PATH = "checkpoints/keypointrcnn_epoch20.pth"
    IMAGE_FOLDER = "skeletons"        # folder with input images
    OUTPUT_FOLDER = "predictions_out"   # where to save visualizations
    SCORE_THRESHOLD = 0.6               # ignore detections below this confidence
    # ---------------------------------------------------

    device = torch.device("cuda") if torch.cuda.is_available() else torch.device("cpu")
    model = load_model(CHECKPOINT_PATH, device)
    apply_model(model, IMAGE_FOLDER, OUTPUT_FOLDER, device, score_threshold=SCORE_THRESHOLD)


if __name__ == "__main__":
    main()
