from train_torch import get_model
from transforms import PILToTensor, Compose
from PIL import Image, ImageDraw
import torch
import numpy as np

labels = torch.load('models/retinanet_labels.model')
labels = {v: k for k, v in labels.items()}

colors = {'text': '#d3d3d3',
         'skeleton_photo': '#556b2f',
         'ceramics': '#8b0000',
         'artefact': '#483d8b',
         'kurgan': '#3cb371',
         'table': '#008080',
         'oxcal': '#b8860b',
         'grave_photo': '#9acd32',
         'map': '#00008b',
         'scale': '#ff0000',
         'arrow': '#ffd700',
         'grave': '#00ff00',
         'skeleton': '#ba55d3',
         'skull': '#00ff7f',
         'good': '#00ffff',
         'grave_cross_section': '#00bfff',
         'stone_tool': '#0000ff',
         'goods': '#f08080',
         'shaft_axe': '#ff00ff',
         'st': 'black',
         'grave_goods': '#dda0dd',
         'bone_tool': '#ff1493',
         'skull_photo': '#f0e68c'}

device = torch.device('cuda')

loaded_model = get_model(num_classes = len(labels.keys()))
loaded_model.load_state_dict(torch.load('models/retinanet_dfg.model'))

loaded_model.eval()

loaded_model.to(device)

image = Image.open('scripts/Dobes & Limbursky_2013_Vlineves-KSK-063.jpg')

img, _ = PILToTensor()(image)

with torch.no_grad():
        prediction = loaded_model([img.to(device)])

image = image.convert('RGB')
draw = ImageDraw.Draw(image)
for element in range(len(prediction[0]["boxes"])):
        boxes = prediction[0]["boxes"][element].cpu().numpy()
        score = np.round(prediction[0]["scores"][element].cpu().numpy(),
                decimals= 4)
        label = str(labels[prediction[0]['labels'][element].cpu().item()])

        if score > 0.7:
                draw.rectangle([(boxes[0]-5, boxes[1]), (boxes[2], boxes[3])], outline=colors[label], width=3)
                draw.text((boxes[0], boxes[1]), text=label + '(' +str(score) + ')', fill=colors[label])

image.save('object detection example.jpg')
