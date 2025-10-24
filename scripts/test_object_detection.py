import torch
import requests
from PIL import Image, ImageDraw
from transformers import AutoModelForObjectDetection, AutoImageProcessor
from transformers import infer_device

device = infer_device()

image = Image.open('scripts/Dobes & Limbursky_2013_Vlineves-KSK-053.jpg').convert('RGB')
processor = AutoImageProcessor.from_pretrained(
  "models/conditional-detr-resnet",
  do_resize=True,
  do_pad=True,
)

model = AutoModelForObjectDetection.from_pretrained(
  "models/conditional-detr-resnet",
  num_labels=21,
  ignore_mismatched_sizes=True # Allow re-initialization of final layer
)
model = model.to(device)

with torch.no_grad():
  inputs = processor(images=[image], return_tensors="pt")
  outputs = model(**inputs.to(device))
  target_sizes = torch.tensor([[image.size[1], image.size[0]]])
  results = processor.post_process_object_detection(outputs, target_sizes=torch.tensor([(image.height, image.width)]), threshold=0.5)
  results = results[0]

# scores = torch.nn.functional.sigmoid(outputs.logits)
# scores, index = torch.topk(scores.flatten(1), num_top_queries, axis=-1)
# num_top_queries = outputs.logits.shape[1]
# scores, index = torch.topk(scores.flatten(1), num_top_queries, axis=-1)
# print(scores)


draw = ImageDraw.Draw(image)

for score, label, box in zip(results["scores"], results["labels"], results["boxes"]):

  box = [round(i, 2) for i in box.tolist()]

  x, y, x2, y2 = tuple(box)

  draw.rectangle((x, y, x2, y2), outline="red", width=1)

  draw.text((x, y), model.config.id2label[label.item()], fill="black")

image.show()
