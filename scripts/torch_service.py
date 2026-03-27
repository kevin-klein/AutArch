from sklearn.cluster import MiniBatchKMeans
from sklearn.metrics.pairwise import cosine_similarity
from bottle import Bottle, request, response
from train_detr import MODEL_SAVE_PATH
from transforms import PILToTensor, Compose
from PIL import Image, ImageDraw
import torch
import numpy as np
import io
import os
import torchvision
from pyefd import elliptic_fourier_descriptors
from mobile_sam import sam_model_registry, SamPredictor
import cv2
import matplotlib.pyplot as plt
from transformers import AutoModelForObjectDetection, AutoImageProcessor
import json
from train_arrow_angle_network import model as arrow_model
from train_object_detection import get_model

def show_mask(mask, ax, random_color=False, borders = True):
    if random_color:
        color = np.concatenate([np.random.random(3), np.array([0.6])], axis=0)
    else:
        color = np.array([30/255, 144/255, 255/255, 0.6])
    h, w = mask.shape[-2:]
    mask = mask.astype(np.uint8)
    mask_image =  mask.reshape(h, w, 1) * color.reshape(1, 1, -1)
    if borders:
        contours, _ = cv2.findContours(mask,cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)
        # Try to smooth contours
        contours = [cv2.approxPolyDP(contour, epsilon=0.01, closed=True) for contour in contours]
        mask_image = cv2.drawContours(mask_image, contours, -1, (1, 0, 0, 0.5), thickness=10)
    ax.imshow(mask_image)

def show_points(coords, labels, ax, marker_size=375):
    pos_points = coords[labels==1]
    neg_points = coords[labels==0]
    ax.scatter(pos_points[:, 0], pos_points[:, 1], color='green', marker='*', s=marker_size, edgecolor='white', linewidth=1.25)
    ax.scatter(neg_points[:, 0], neg_points[:, 1], color='red', marker='*', s=marker_size, edgecolor='white', linewidth=1.25)

def show_box(box, ax):
    x0, y0 = box[0], box[1]
    w, h = box[2] - box[0], box[3] - box[1]
    ax.add_patch(plt.Rectangle((x0, y0), w, h, edgecolor='green', facecolor=(0, 0, 0, 0), lw=2))

def show_masks(image, masks, scores, point_coords=None, box_coords=None, input_labels=None, borders=True):
    for i, (mask, score) in enumerate(zip(masks, scores)):
        plt.figure(figsize=(10, 10))
        plt.imshow(image)
        show_mask(mask, plt.gca(), borders=borders)
        if point_coords is not None:
            assert input_labels is not None
            show_points(point_coords, input_labels, plt.gca())
        if box_coords is not None:
            # boxes
            show_box(box_coords, plt.gca())
        if len(scores) > 1:
            plt.title(f"Mask {i+1}, Score: {score:.3f}", fontsize=18)
        plt.axis('off')
        plt.show()

labels = torch.load('models/faster_rcnn_v2.model')
labels = {v: k for k, v in labels.items()}

if torch.cuda.is_available():
    device = torch.device('cuda')
else:
    device = torch.device('cpu')

sam_checkpoint = "models/mobile_sam.pt"
model_type = 'vit_t'

# Load BOVW vocabulary if available
BOVW_VOCABULARY_PATH = "models/bovw_vocabulary.pkl"
bovw_vocabulary = None
try:
    if os.path.exists(BOVW_VOCABULARY_PATH):
        with open(BOVW_VOCABULARY_PATH, 'rb') as f:
            bovw_vocabulary = pickle.load(f)
        print(f"Loaded BOVW vocabulary from {BOVW_VOCABULARY_PATH}")
except Exception as e:
    print(f"Failed to load BOVW vocabulary: {e}")

sam = sam_model_registry[model_type](checkpoint=sam_checkpoint)
sam.to(device=device)
sam.eval()

loaded_model = get_model(num_classes = len(labels.keys()), device=device)
loaded_model.load_state_dict(torch.load('models/rcnn_fpn.model', map_location=device))

id2label = {v: k for k, v in labels.items()}
label2id = labels

# processor = AutoImageProcessor.from_pretrained(
#     MODEL_SAVE_PATH,
#     do_resize=True,
#     do_pad=True,
# )

# loaded_model = AutoModelForObjectDetection.from_pretrained(
#     MODEL_SAVE_PATH,
#     id2label=id2label,
#     label2id=label2id,
#     num_labels=len(labels),
#     ignore_mismatched_sizes=True
# )

loaded_model.eval()

loaded_model.to(device)

app = Bottle()
arrow_model = arrow_model.to(device)

arrow_model.load_state_dict(torch.load('models/arrow_convnext.model', map_location=device, weights_only=True))

# skeleton_orientation_model = model = torchvision.models.resnet152(weights=None)
# skeleton_orientation_model.fc = torch.nn.Linear(in_features=2048, out_features=2, bias=True)
# skeleton_orientation_model.to(device)

skeleton_labels = torch.load('models/skeleton_resnet_labels.model', map_location=device)
skeleton_model = torchvision.models.convnext_tiny(weights=None, num_classes=len(skeleton_labels)).to(device)
skeleton_model.load_state_dict(torch.load('models/skeleton_convnext_tiny.model', map_location=device))

# sam = sam_model_registry["vit_h"](checkpoint="models/sam_vit_h_4b8939.pth")
# sam.to(device)
predictor = SamPredictor(sam)

# quantization_config = BitsAndBytesConfig(
#     load_in_4bit=True,
#     bnb_4bit_compute_dtype=torch.bfloat16,
#     bnb_4bit_quant_type="nf4"
# )
# tokenizer = AutoTokenizer.from_pretrained(
#     "google/pegasus-cnn_dailymail"
# )
# print(tokenizer.max_len_single_sentence)
# model = AutoModelForSeq2SeqLM.from_pretrained(
#     "google/pegasus-cnn_dailymail",
#     dtype=torch.bfloat16,
#     device_map="auto",
#     quantization_config=quantization_config
# )

def extract_local_features(image_array, feature_type='sift'):
    """
    Extract local features from an image.
    Supports SIFT and ORB features.
    """
    if feature_type == 'sift':
        # Initialize SIFT detector
        sift = cv2.SIFT_create()
        keypoints, descriptors = sift.detectAndCompute(image_array, None)

        if descriptors is not None:
            return descriptors
        else:
            return None
    elif feature_type == 'orb':
        # Initialize ORB detector
        orb = cv2.ORB_create(nfeatures=1000)
        keypoints, descriptors = orb.detectAndCompute(image_array, None)

        if descriptors is not None:
            return descriptors
        else:
            return None
    else:
        raise ValueError(f"Unknown feature type: {feature_type}")

def train_visual_vocabulary(image_paths, n_clusters=32, feature_type='sift'):
    """
    Train a Bag of Visual Words vocabulary using K-Means clustering.
    """
    print("Extracting features for vocabulary training...")

    # Extract features from all images
    all_features = []
    for img_path in image_paths:
        img = cv2.imread(img_path)
        if img is None:
            continue

        # Convert to grayscale
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

        # Extract features
        descriptors = extract_local_features(gray, feature_type)

        if descriptors is not None:
            all_features.append(descriptors)

    # Concatenate all features
    if len(all_features) == 0:
        raise ValueError("No features extracted from images")

    all_features = np.vstack(all_features)

    print(f"Training K-Means with {n_clusters} clusters on {all_features.shape[0]} features...")

    # Train K-Means
    kmeans = MiniBatchKMeans(n_clusters=n_clusters, random_state=42, n_init=10)
    kmeans.fit(all_features)

    print(f"Visual vocabulary trained! Vocabulary shape: {kmeans.cluster_centers_.shape}")

    return kmeans

def compute_bovw_features(image_array, vocabulary, feature_type='sift'):
    """
    Compute Bag of Visual Words features for an image.
    """
    # Extract local features
    descriptors = extract_local_features(image_array, feature_type)

    if descriptors is None:
        # Return zero vector if no features found
        return np.zeros(vocabulary.n_clusters)

    # Assign each feature to the nearest visual word
    distances = vocabulary.transform(descriptors)
    labels = distances.argmax(axis=1)

    # Create histogram of visual word occurrences
    hist, _ = np.histogram(labels, bins=vocabulary.n_clusters, range=(0, vocabulary.n_clusters))

    # L2 normalize the histogram
    norm = np.linalg.norm(hist)
    if norm > 0:
        hist = hist / norm

    return hist.tolist()

def object_features(file, vocabulary=None):
    """
    Extract BOVW features from an image.
    If vocabulary is provided, uses BOVW. Otherwise uses backbone features as fallback.
    """
    request_object_content = file.read()
    img = Image.open(io.BytesIO(request_object_content)).resize((200, 200), Image.Resampling.BILINEAR)

    # Convert PIL image to numpy array
    img_array = np.array(img)

    # Try BOVW if vocabulary is provided
    if vocabulary is not None:
        try:
            bovw_features = compute_bovw_features(img_array, vocabulary, feature_type='sift')
            return bovw_features
        except Exception as e:
            print(f"BOVW extraction failed: {e}, falling back to backbone features")

    # Fallback to backbone features
    img_pil = Image.open(io.BytesIO(request_object_content)).resize((200, 200), Image.Resampling.BILINEAR)
    img_tensor, _ = PILToTensor()(img_pil)
    img_tensor = torch.stack([img_tensor]).to(device)

    with torch.no_grad():
        loaded_model.backbone.eval()
        return loaded_model.backbone(img_tensor)

def analyze_file(file):
    request_object_content = file.read()
    pil_image = Image.open(io.BytesIO(request_object_content))

    img, _ = PILToTensor()(pil_image)

    with torch.no_grad():
        prediction = loaded_model([img.to(device)])

    result = []
    for element in range(len(prediction[0]["boxes"])):
            boxes = prediction[0]["boxes"][element].cpu().numpy().tolist()
            score = np.round(prediction[0]["scores"][element].cpu().numpy(),
                    decimals= 4)

            label = labels[prediction[0]['labels'][element].cpu().item()]

            if score > 0.1:
                result.append({
                    'score': score.tolist(),
                    'box': boxes,
                    'label': label
                })
    del img
    return result

def analyze_arrow(file):
    request_object_content = file.read()
    img = Image.open(io.BytesIO(request_object_content))

    img, _ = PILToTensor()(img)
    img = torch.stack([img]).to(device)

    with torch.no_grad():
        arrow_model.eval()
        prediction = arrow_model(img)

    return prediction

def analyze_skeleton_orientation(file):
    request_object_content = file.read()
    img = Image.open(io.BytesIO(request_object_content))

    img, _ = PILToTensor()(img)
    img = torch.stack([img]).to(device)

    with torch.no_grad():
        skeleton_orientation_model.eval()
        prediction = skeleton_orientation_model(img)

    return prediction

def analyze_skeleton(file):
    request_object_content = file.read()
    img = Image.open(io.BytesIO(request_object_content))

    img, _ = PILToTensor()(img)
    img = torch.stack([img]).to(device)

    with torch.no_grad():
        skeleton_model.eval()
        prediction = skeleton_model(img)

        _, prediction = torch.max(prediction, 1)

    return skeleton_labels[prediction]

def save_masks_as_images(masks, output_dir="masks_out"):
    """
    Save all boolean masks to image files.
    Args:
        masks: np.ndarray or torch.Tensor of shape (N, H, W), dtype=bool
        output_dir: folder to save the images
    """
    os.makedirs(output_dir, exist_ok=True)

    # Convert PyTorch tensor to NumPy if needed
    if isinstance(masks, torch.Tensor):
        masks = masks.cpu().numpy()

    for i, mask in enumerate(masks):
        # Convert boolean mask (True/False) to 0–255 grayscale image
        img = (mask.astype(np.uint8)) * 255
        im = Image.fromarray(img, mode="L")
        im.save(os.path.join(output_dir, f"mask_{i:03d}.png"))

    print(f"Saved {len(masks)} masks to '{output_dir}/'")

# @app.post('/summary')
# def summarize():
#     text = request.POST['text']

#     input_ids = tokenizer(text, return_tensors="pt").to(model.device)
#     output = model.generate(**input_ids, cache_implementation="static")

#     print(output)

#     return {
#         'summary': tokenizer.decode(output[0], skip_special_tokens=True)
#     }

@app.post('/segment')
def segment_route():
    upload_file = request.POST['image']
    points = request.POST['points']
    request_object_content = upload_file.file.read()
    pil_image = Image.open(io.BytesIO(request_object_content))
    open_cv_image = np.array(pil_image)

    height, width, channels = open_cv_image.shape

    predictor.set_image(open_cv_image)

    points = json.loads(points)
    input_point = np.array(points)
    input_label = np.array([1] * len(points))

    masks, scores, logits = predictor.predict(
        point_coords=input_point,
        point_labels=input_label,
        multimask_output=False,
    )

    # save_masks_as_images(masks)

    mask_sizes = masks.sum(axis=(1, 2))

    largest_idx = mask_sizes.argmax()

    mask = masks[largest_idx]
    score = scores[largest_idx]

    h, w = mask.shape[-2:]
    mask = mask.reshape(h, w)

    mask = mask.astype(dtype='uint8')
    mask *= 255

    contours, _  = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)

    return { 'predictions': {
        'score': score.item(),
        'contour': [contour[:, 0, :].astype(int).tolist() for contour in contours]
    } }

@app.post('/')
def upload():
    upload_file = request.POST['image']
    result = analyze_file(upload_file.file)

    return { 'predictions': result }

@app.post('/arrow')
def upload_arrow():
    upload_file = request.POST['image']
    result = analyze_arrow(upload_file.file)

    return { 'predictions': result.tolist()[0] }

@app.post('/skeleton')
def upload_skeleton():
    upload_file = request.POST['image']

    result = analyze_skeleton(upload_file.file)

    return { 'predictions': result }

# @app.post('/skeleton-orientation')
# def upload_skeleton_angle():
#     upload_file = request.POST['image']
#     result = analyze_skeleton_orientation(upload_file.file)

#     return { 'predictions': result }

@app.post('/efd')
def efd():
    data = request.json
    coeffs = elliptic_fourier_descriptors(data['contour'], order=data['order'], normalize=data['normalize'], return_transformation=data['return_transformation'])

    return {
        'efds': coeffs.tolist()
    }

@app.post('/train_bovw')
def train_bovw():
    """
    Train a new Bag of Visual Words vocabulary and create a similarity matrix of all images.
    Expects a list of image paths in the request body.
    """
    images = request.json['images']
    n_clusters = request.json.get('n_clusters', 128)
    feature_type = request.json.get('feature_type', 'sift')

    try:
        # Train vocabulary
        vocabulary = train_visual_vocabulary(images, n_clusters, feature_type)

        # Extract BOVW features for all images
        print("Extracting BOVW features for all images...")
        all_features = []
        for img_path in images:
            img = cv2.imread(img_path)
            if img is None:
                continue

            gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
            descriptors = extract_local_features(gray, feature_type)

            if descriptors is not None:
                # Assign each feature to nearest visual word
                distances = vocabulary.transform(descriptors)
                labels = distances.argmax(axis=1)

                # Create histogram
                hist, _ = np.histogram(labels, bins=vocabulary.n_clusters, range=(0, vocabulary.n_clusters))

                # L2 normalize
                norm = np.linalg.norm(hist)
                if norm > 0:
                    hist = hist / norm

                all_features.append(hist)

        all_features = np.array(all_features)

        # Compute similarity matrix (cosine similarity)
        print("Computing similarity matrix...")
        similarity_matrix = cosine_similarity(all_features)

        return {
            'success': True,
            'n_clusters': n_clusters,
            'feature_type': feature_type,
            'n_images': len(all_features),
            'similarity_matrix': similarity_matrix.tolist()
        }

    except Exception as e:
        return {
            'success': False,
            'error': str(e)
        }

if __name__ == '__main__':
    # Check if we're in production mode
    production = os.environ.get('RAILS_ENV') == 'production'

    if production:
        # Production configuration
        app.run(host='127.0.0.1', port=9000, server='waitress')
    else:
        # Development configuration
        app.run(debug=True, reloader=True, host='0.0.0.0', port=9000)
