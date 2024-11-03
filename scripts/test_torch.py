from scripts.train_object_detection import get_model
from transforms import PILToTensor, Compose
from PIL import Image, ImageDraw
import torch
import numpy as np
import os

labels = torch.load('models/rcnn_labels_large.model')
labels = {v: k for k, v in labels.items()}

device = torch.device('cuda')

loaded_model = get_model(num_classes = len(labels.keys()))
loaded_model.load_state_dict(torch.load('models/rcnn_dfg_large.model'))

loaded_model.eval()

loaded_model.to(device)

for image_name in os.listdir('pdfs/page_images'):
        if not image_name.endswith('.jpg'):
                continue
        image = Image.open(os.path.join('pdfs', 'page_images', image_name))
        img, _ = PILToTensor()(image)

        with torch.no_grad():
                prediction = loaded_model([img.to(device)])

        draw = ImageDraw.Draw(image)
        for element in range(len(prediction[0]["boxes"])):
                boxes = prediction[0]["boxes"][element].cpu().numpy()
                score = np.round(prediction[0]["scores"][element].cpu().numpy(),
                        decimals= 4)

                if score > 0.8:
                        print(score)
                        draw.rectangle([(boxes[0], boxes[1]), (boxes[2], boxes[3])],
                        outline ="red", width =3)
                        draw.text((boxes[0], boxes[1]), text = str(labels[prediction[0]['labels'][element].cpu().item()]), fill="red")

        image.save(os.path.join('pdfs/annotations ssd', image_name))
