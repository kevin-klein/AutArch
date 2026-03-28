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
import pickle

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

# if torch.cuda.is_available():
#     device = torch.device('cuda')
# else:
#     device = torch.device('cpu')
device = torch.device('cpu')

sam_checkpoint = "models/mobile_sam.pt"
model_type = 'vit_t'

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
    Extract local features from an image with quality filtering.
    Supports SIFT and ORB features.
    """
    if feature_type == 'sift':
        # Initialize SIFT detector with better parameters
        sift = cv2.SIFT_create(
            nfeatures=0,  # No limit
            nOctaveLayers=3,
            contrastThreshold=0.02,  # Lower = more features
            edgeThreshold=10,
            sigma=1.6
        )
        keypoints, descriptors = sift.detectAndCompute(image_array, None)

        if descriptors is not None and len(keypoints) > 0:
            # Filter low-quality descriptors based on response
            responses = np.array([kp.response for kp in keypoints])
            threshold = np.percentile(responses, 25)  # Keep top 75%
            quality_mask = responses > threshold
            if np.any(quality_mask):
                descriptors = descriptors[quality_mask]
            return descriptors, keypoints
        return None, None
    elif feature_type == 'orb':
        # Initialize ORB detector
        orb = cv2.ORB_create(nfeatures=1000, scoreType=cv2.ORB_FAST_SCORE)
        keypoints, descriptors = orb.detectAndCompute(image_array, None)

        if descriptors is not None and len(keypoints) > 0:
            return descriptors, keypoints
        return None, None
    else:
        raise ValueError(f"Unknown feature type: {feature_type}")

def train_visual_vocabulary(image_paths, n_clusters=32, feature_type='sift'):
    """
    Train a Bag of Visual Words vocabulary optimized for small datasets of circular objects.
    Focuses on surface decoration patterns rather than spatial position.
    """
    print("Extracting features for vocabulary training...")
    n_images = len(image_paths)

    # For small datasets, use fewer clusters to avoid overfitting
    # Rule of thumb: at least 2-3 images per cluster
    max_clusters = max(16, min(n_clusters, n_images * 3))
    if max_clusters != n_clusters:
        print(f"Adjusted clusters from {n_clusters} to {max_clusters} for small dataset")

    # Extract features from all images
    all_features = []
    feature_counts = []

    for img_path in image_paths:
        img = cv2.imread(img_path)
        if img is None:
            print(f"Warning: Could not read {img_path}")
            continue

        # Convert to LAB color space - better for texture/color analysis
        lab = cv2.cvtColor(img, cv2.COLOR_BGR2LAB)

        # Use L channel (lightness) for texture detection
        l_channel = lab[:,:,0]

        # Apply CLAHE for better contrast in surface decorations
        clahe = cv2.createCLAHE(clipLimit=3.0, tileGridSize=(8,8))
        enhanced = clahe.apply(l_channel)

        # Extract features with quality filtering
        descriptors, keypoints = extract_local_features(enhanced, feature_type)

        if descriptors is not None and len(descriptors) > 0:
            # For small datasets, keep more features per image
            if len(descriptors) >= 5:
                all_features.append(descriptors)
                feature_counts.append(len(descriptors))

    # Check if we have enough features
    if len(all_features) == 0:
        raise ValueError("No features extracted from images")

    # Concatenate all features
    all_features = np.vstack(all_features)
    print(f"Total features extracted: {all_features.shape[0]}")
    print(f"Average features per image: {np.mean(feature_counts):.1f}")

    # For small datasets, avoid PCA which can lose information
    # Use standard K-Means with more iterations for stability
    n_init = max(20, min(100, n_images * 10))

    print(f"Training K-Means with {max_clusters} clusters on {all_features.shape[0]} features...")
    kmeans = MiniBatchKMeans(
        n_clusters=max_clusters,
        random_state=42,
        n_init=n_init,
        batch_size=min(32, all_features.shape[0])
    )
    kmeans.fit(all_features)

    print(f"Visual vocabulary trained! Vocabulary shape: {kmeans.cluster_centers_.shape}")

    return kmeans

def compute_bovw_features(image_array, vocabulary, feature_type='sift'):
    """
    Compute Bag of Visual Words features for an image with TF-IDF weighting.
    Optimized for small datasets of surface decorations.
    """
    # Extract local features
    descriptors, keypoints = extract_local_features(image_array, feature_type)

    if descriptors is None or len(descriptors) == 0:
        # Return zero vector if no features found
        return np.zeros(vocabulary.n_clusters), None

    # Assign each feature to the nearest visual word
    distances = vocabulary.transform(descriptors)
    word_labels = distances.argmax(axis=1)

    # Create histogram of visual word occurrences
    hist, _ = np.histogram(word_labels, bins=vocabulary.n_clusters, range=(0, vocabulary.n_clusters))

    # TF-IDF weighting optimized for small datasets
    # Use smoother IDF to avoid extreme weights with few documents
    # Formula: log((N + 1) / (df + 1)) + 1 where N = total images, df = document frequency
    idf = np.log((vocabulary.n_clusters + 1) / (hist + 1)) + 1

    # Apply TF-IDF weighting
    tfidf_hist = hist * idf

    # L2 normalize the weighted histogram
    norm = np.linalg.norm(tfidf_hist)
    if norm > 0:
        tfidf_hist = tfidf_hist / norm

    return tfidf_hist.tolist(), word_labels

def object_features(file, vocabulary=None):
    """
    Extract BOVW features from an image.
    If vocabulary is provided, uses BOVW with TF-IDF. Otherwise uses backbone features as fallback.
    """
    request_object_content = file.read()
    img = Image.open(io.BytesIO(request_object_content))

    # Convert PIL image to numpy array
    img_array = np.array(img)

    # Try BOVW if vocabulary is provided
    if vocabulary is not None:
        try:
            # Use same preprocessing as training
            if len(img_array.shape) == 3:
                lab = cv2.cvtColor(img_array, cv2.COLOR_BGR2LAB)
                l_channel = lab[:,:,0]
                clahe = cv2.createCLAHE(clipLimit=3.0, tileGridSize=(8,8))
                enhanced = clahe.apply(l_channel)
            else:
                enhanced = img_array

            bovw_features, _ = compute_bovw_features(enhanced, vocabulary, feature_type='sift')
            return bovw_features
        except Exception as e:
            print(f"BOVW extraction failed: {e}, falling back to backbone features")

    # Fallback to backbone features
    pil_image = Image.open(io.BytesIO(request_object_content))
    img_tensor, _ = PILToTensor()(pil_image)
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

@app.post('/color_bovw')
def color_bovw():
    """
    Compute BOVW using color histograms instead of SIFT.
    Better for small datasets where color patterns are important.
    """
    images = request.json['images']
    n_bins = request.json.get('n_bins', 64)

    try:
        all_features = []
        valid_images = []

        for img_path in images:
            img = cv2.imread(img_path)
            if img is None:
                continue

            # Compute color histogram in LAB color space
            lab = cv2.cvtColor(img, cv2.COLOR_BGR2LAB)

            # Histogram for each channel
            hist_l = cv2.calcHist([lab], [0], None, [n_bins], [0, 256])
            hist_a = cv2.calcHist([lab], [1], None, [n_bins], [-128, 128])
            hist_b = cv2.calcHist([lab], [2], None, [n_bins], [-128, 128])

            # Concatenate channels
            color_hist = np.concatenate([hist_l, hist_a, hist_b])

            # L2 normalize
            norm = np.linalg.norm(color_hist)
            if norm > 0:
                color_hist = color_hist / norm

            all_features.append(color_hist)
            valid_images.append(img_path)

        if len(all_features) == 0:
            raise ValueError("No valid images")

        all_features = np.array(all_features)

        # Compute similarity
        similarity_matrix = cosine_similarity(all_features)

        return {
            'success': True,
            'n_bins': n_bins,
            'n_images': len(all_features),
            'similarity_matrix': similarity_matrix.tolist(),
            'valid_images': valid_images
        }

    except Exception as e:
        import traceback
        return {
            'success': False,
            'error': str(e),
            'traceback': traceback.format_exc()
        }

@app.post('/pattern_match')
def pattern_match():
    """
    Match pattern parts from a query image against a database of pattern parts.
    Expects:
    - query_image: image path or base64
    - pattern_boxes: list of [x1, y1, x2, y2] rectangles
    - target_images: list of image paths to search in
    - feature_type: 'texture', 'color', or 'edge'

    Returns matches with similarity scores.
    """
    query_image_path = request.json.get('query_image')
    pattern_boxes = request.json.get('pattern_boxes', [])
    target_images = request.json.get('target_images', [])
    feature_type = request.json.get('feature_type', 'texture')

    try:
        if not pattern_boxes:
            raise ValueError("No pattern boxes provided")

        # Load query image
        query_img = cv2.imread(query_image_path)
        if query_img is None:
            raise ValueError(f"Could not load query image: {query_image_path}")

        # Extract features from query pattern boxes
        query_features = []
        for i, box in enumerate(pattern_boxes):
            x1, y1, x2, y2 = box
            # Extract ROI
            roi = query_img[y1:y2, x1:x2]
            if roi.size == 0:
                continue

            feature = extract_pattern_feature(roi, feature_type)
            if feature is not None:
                query_features.append({
                    'box': box,
                    'feature': feature,
                    'index': i
                })

        if not query_features:
            raise ValueError("Could not extract features from pattern boxes")

        # Match against target images
        matches = []
        for target_path in target_images:
            target_img = cv2.imread(target_path)
            if target_img is None:
                continue

            # Extract features from all possible regions in target
            target_matches = []
            for qf in query_features:
                # Slide window approach or direct comparison
                # For small patterns, use template matching
                query_roi = query_img[qf['box'][1]:qf['box'][3], qf['box'][0]:qf['box'][2]]

                # Use template matching for texture/edge features
                if feature_type in ['texture', 'edge']:
                    matches_loc = cv2.matchTemplate(target_img, query_roi, cv2.TM_CCOEFF_NORMED)
                    min_val, max_val, min_loc, max_loc = cv2.minMaxLoc(matches_loc)

                    if max_val > 0.6:  # Threshold for match
                        h, w = query_roi.shape[:2]
                        target_matches.append({
                            'query_box': qf['box'],
                            'target_box': [max_loc[0], max_loc[1], max_loc[0] + w, max_loc[1] + h],
                            'similarity': max_val,
                            'target_image': target_path
                        })

                # For color features, compare histograms
                elif feature_type == 'color':
                    target_hist = extract_pattern_feature(target_img, 'color')
                    if target_hist is not None:
                        # Compare histograms
                        similarity = cv2.compareHist(qf['feature'], target_hist, cv2.HISTCMP_CORREL)
                        if similarity > 0.7:
                            # Find approximate location (center of image for now)
                            h, w = target_img.shape[:2]
                            target_matches.append({
                                'query_box': qf['box'],
                                'target_box': [w//4, h//4, 3*w//4, 3*h//4],
                                'similarity': similarity,
                                'target_image': target_path
                            })

            matches.extend(target_matches)

        # Sort by similarity
        matches.sort(key=lambda x: x['similarity'], reverse=True)

        return {
            'success': True,
            'n_query_patterns': len(query_features),
            'n_matches': len(matches),
            'matches': matches
        }

    except Exception as e:
        import traceback
        return {
            'success': False,
            'error': str(e),
            'traceback': traceback.format_exc()
        }

def extract_pattern_feature(image_array, feature_type='texture'):
    """
    Extract features from a pattern region.
    """
    if feature_type == 'texture':
        # Use SIFT descriptors
        sift = cv2.SIFT_create()
        keypoints, descriptors = sift.detectAndCompute(image_array, None)

        if descriptors is not None and len(descriptors) > 0:
            # Create histogram of SIFT descriptors
            # For simplicity, use mean descriptor
            return descriptors.mean(axis=0).tolist()
        return None

    elif feature_type == 'color':
        # Compute LAB color histogram
        lab = cv2.cvtColor(image_array, cv2.COLOR_BGR2LAB)
        hist_l = cv2.calcHist([lab], [0], None, [32], [0, 256])
        hist_a = cv2.calcHist([lab], [1], None, [32], [-128, 128])
        hist_b = cv2.calcHist([lab], [2], None, [32], [-128, 128])
        hist = np.concatenate([hist_l, hist_a, hist_b])
        return hist.flatten()

    elif feature_type == 'edge':
        # Use Canny edge detection + histogram of gradients
        gray = cv2.cvtColor(image_array, cv2.COLOR_BGR2GRAY)
        edges = cv2.Canny(gray, 50, 150)

        # Compute HOG-like feature
        # Simplified: count edge pixels and orientations
        orientations = np.arctan2(*np.gradient(edges)[::-1])
        hist, _ = np.histogram(orientations, bins=18, range=(-np.pi, np.pi))
        return hist.tolist()

    return None

@app.post('/train_bovw')
def train_bovw():
    """
    Train a new Bag of Visual Words vocabulary and create a similarity matrix.
    Optimized for small datasets of circular objects with surface decorations.
    """
    images = request.json['images']
    n_clusters = request.json.get('n_clusters', 32)
    feature_type = request.json.get('feature_type', 'sift')

    try:
        # Train vocabulary
        vocabulary = train_visual_vocabulary(images, n_clusters, feature_type)

        # Extract BOVW features for all images with TF-IDF
        print("Extracting BOVW features for all images...")
        all_features = []
        valid_images = []

        for img_path in images:
            img = cv2.imread(img_path)
            if img is None:
                print(f"Warning: Could not read {img_path}")
                continue

            # Use same preprocessing as training
            lab = cv2.cvtColor(img, cv2.COLOR_BGR2LAB)
            l_channel = lab[:,:,0]
            clahe = cv2.createCLAHE(clipLimit=3.0, tileGridSize=(8,8))
            enhanced = clahe.apply(l_channel)

            descriptors, _ = extract_local_features(enhanced, feature_type)

            if descriptors is not None and len(descriptors) > 0:
                # Compute BOVW histogram
                distances = vocabulary.transform(descriptors)
                word_labels = distances.argmax(axis=1)

                # Create histogram
                hist, _ = np.histogram(word_labels, bins=vocabulary.n_clusters, range=(0, vocabulary.n_clusters))

                # TF-IDF weighting (same as training)
                idf = np.log((vocabulary.n_clusters + 1) / (hist + 1)) + 1
                tfidf_hist = hist * idf

                # L2 normalize
                norm = np.linalg.norm(tfidf_hist)
                if norm > 0:
                    tfidf_hist = tfidf_hist / norm

                all_features.append(tfidf_hist)
                valid_images.append(img_path)

        if len(all_features) == 0:
            raise ValueError("No valid features extracted from images")

        all_features = np.array(all_features)
        print(f"Extracted features from {len(valid_images)} images")

        # Compute similarity matrix using cosine similarity
        # For small datasets, also compute correlation-based similarity
        print("Computing similarity matrix...")
        cosine_sim = cosine_similarity(all_features)

        # Alternative: Pearson correlation (better for small datasets)
        # This measures pattern similarity rather than magnitude
        correlation_sim = np.corrcoef(all_features)
        # Handle NaN values from constant vectors
        correlation_sim = np.nan_to_num(correlation_sim, nan=0.0)

        correlation_sim = (-correlation_sim - (-1)) / 2
        cosine_sim = (-cosine_sim - (-1)) / 2

        # Blend both similarities (cosine focuses on direction, correlation on pattern)
        blended_sim = 0.8 * cosine_sim + 0.2 * correlation_sim

        return {
            'success': True,
            'n_clusters': vocabulary.n_clusters,
            'feature_type': feature_type,
            'n_images': len(all_features),
            'similarity_matrix': blended_sim.tolist(),
            'valid_images': valid_images,
            'metrics': {
                'cosine_only': cosine_sim.tolist(),
                'correlation_only': correlation_sim.tolist()
            }
        }

    except Exception as e:
        import traceback
        return {
            'success': False,
            'error': str(e),
            'traceback': traceback.format_exc()
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
