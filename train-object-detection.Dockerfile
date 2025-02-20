FROM pytorch/pytorch:2.5.1-cuda12.4-cudnn9-runtime

COPY scripts ./scripts
COPY training_data ./training_data

CMD [ "python", "scripts/train_object_detection.py" ]
