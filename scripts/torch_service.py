from bottle import Bottle, request, response
from train_torch import get_model
from transforms import PILToTensor, Compose
from PIL import Image, ImageDraw
import torch
import numpy as np
import io
import os

labels = torch.load('models/rcnn_labels_large.model')
labels = {v: k for k, v in labels.items()}

device = torch.device('cuda')

loaded_model = get_model(num_classes = len(labels.keys()))
loaded_model.load_state_dict(torch.load('models/rcnn_dfg_large.model'))

loaded_model.eval()

loaded_model.to(device)

app = Bottle()

def analyse_file(file):
    request_object_content = file.read()
    img = Image.open(io.BytesIO(request_object_content))

    img, _ = PILToTensor()(img)

    with torch.no_grad():
            prediction = loaded_model([img.to(device)])

    result = []
    for element in range(len(prediction[0]["boxes"])):
            boxes = prediction[0]["boxes"][element].cpu().numpy().tolist()
            score = np.round(prediction[0]["scores"][element].cpu().numpy(),
                    decimals= 4)

            label = labels[prediction[0]['labels'][element].cpu().item()]

            if score > 0.8:
                result.append({
                    'score': score.tolist(),
                    'box': boxes,
                    'label': label
                })
    return result

@app.post('/')
def uplad():
    upload_file = request.POST['image']
    result = analyse_file(upload_file.file)

    return { 'predictions': result }

if __name__ == '__main__':
    app.run(debug=True, reloader=True)
