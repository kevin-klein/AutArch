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

def show_mask(mask, ax, random_color=False, borders = True):
    if random_color:
        color = np.concatenate([np.random.random(3), np.array([0.6])], axis=0)
    else:
        color = np.array([30/255, 144/255, 255/255, 0.6])
    h, w = mask.shape[-2:]
    mask = mask.astype(np.uint8)
    mask_image =  mask.reshape(h, w, 1) * color.reshape(1, 1, -1)
    if borders:
        import cv2
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

labels = torch.load('models/retinanet_v2_labels.model')
labels = {v: k for k, v in labels.items()}

if torch.cuda.is_available():
    device = torch.device('cuda')
else:
    device = torch.device('cpu')

sam_checkpoint = "models/mobile_sam.pt"
model_type = 'vit_t'

sam = sam_model_registry[model_type](checkpoint=sam_checkpoint)
sam.to(device=device)
sam.eval()

# loaded_model = get_model(num_classes = len(labels.keys()), device=device)
# loaded_model.load_state_dict(torch.load('models/retinanet_v2_dfg.model', map_location=device))

id2label = {v: k for k, v in labels.items()}
label2id = labels

processor = AutoImageProcessor.from_pretrained(
    MODEL_SAVE_PATH,
    do_resize=True,
    do_pad=True,
)

loaded_model = AutoModelForObjectDetection.from_pretrained(
    MODEL_SAVE_PATH,
    id2label=id2label,
    label2id=label2id,
    num_labels=len(labels),
    ignore_mismatched_sizes=True
)

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

sam = sam_model_registry["vit_h"](checkpoint="models/sam_vit_h_4b8939.pth")
sam.to(device)
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

def object_features(file):
    request_object_content = file.read()
    img = Image.open(io.BytesIO(request_object_content)).resize((200, 200), Image.Resampling.BILINEAR)

    img, _ = PILToTensor()(img)
    img = torch.stack([img]).to(device)

    with torch.no_grad():
        loaded_model.backbone.eval()
        return loaded_model.backbone(img)

def analyze_file(file):
    request_object_content = file.read()
    img = Image.open(io.BytesIO(request_object_content))

    with torch.no_grad():
        inputs = processor(images=[img], return_tensors="pt")
        outputs = loaded_model(**inputs.to(device))
        results = processor.post_process_object_detection(outputs, target_sizes=torch.tensor([(img.height, img.width)]), threshold=0.5)
        prediction = results[0]

    result = []
    for element in range(len(prediction["boxes"])):
            boxes = prediction["boxes"][element].cpu().numpy().tolist()
            score = np.round(prediction["scores"][element].cpu().numpy(),
                    decimals= 4)

            label = labels[prediction['labels'][element].cpu().item()]

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

# @app.post('/features')
# def upload_features():
#     upload_file = request.POST['image']
#     result = object_features(upload_file.file)

#     return { 'features': result['p7'].tolist()[0] }

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

if __name__ == '__main__':
    app.run(debug=True, reloader=True, host='0.0.0.0', port=9000)
