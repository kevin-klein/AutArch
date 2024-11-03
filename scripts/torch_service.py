from bottle import Bottle, request, response
from train_object_detection import get_model
from transforms import PILToTensor, Compose
from PIL import Image, ImageDraw
import torch
import numpy as np
import io
import os
import torchvision

labels = torch.load('models/retinanet_v2_labels.model')
labels = {v: k for k, v in labels.items()}

if torch.cuda.is_available():
    device = torch.device('cuda')
else:
    device = torch.device('cpu')

loaded_model = get_model(num_classes = len(labels.keys()), device=device)
loaded_model.load_state_dict(torch.load('models/retinanet_v2_dfg.model', map_location=device))

loaded_model.eval()

loaded_model.to(device)

app = Bottle()
arrow_model = torchvision.models.resnet152(weights=torchvision.models.ResNet152_Weights.IMAGENET1K_V2)
arrow_model.fc = torch.nn.Linear(in_features=2048, out_features=2, bias=True)
arrow_model = arrow_model.to(device)

arrow_model.load_state_dict(torch.load('models/arrow_resnet.model', map_location=device))

skeleton_orientation_model = model = torchvision.models.resnet152(weights=torchvision.models.ResNet152_Weights.IMAGENET1K_V2)
skeleton_orientation_model.fc = torch.nn.Linear(in_features=2048, out_features=2, bias=True)
skeleton_orientation_model.to(device)

skeleton_model = torchvision.models.resnet152(weights=None, num_classes=2).to(device)
skeleton_model.load_state_dict(torch.load('models/skeleton_resnet.model', map_location=device))
skeleton_labels = torch.load('models/skeleton_resnet_labels.model', map_location=device)

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
        print(prediction)
        print(skeleton_labels)
        _, prediction = torch.max(prediction, 1)

    return skeleton_labels[prediction]

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
def upload_arrow():
    upload_file = request.POST['image']
    result = analyze_skeleton(upload_file.file)

    return { 'predictions': result }

@app.post('/skeleton-orientation')
def upload_skeleton_angle():
    upload_file = request.POST['image']
    result = analyze_skeleton_orientation(upload_file.file)

    return { 'predictions': result }

if __name__ == '__main__':
    app.run(debug=True, reloader=True, host='127.0.0.1')
