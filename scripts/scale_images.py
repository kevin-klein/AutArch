from gluoncv.model_zoo import get_model
import mxnet as mx
from mxnet import gluon
import pandas as pd
import mxnet.ndarray as nd
import cv2 as cv

from gluoncv import model_zoo, data, utils
from matplotlib import pyplot as plt
import os

for file in os.listdir('pdfs/page_images/'):
    if not file.endswith('.jpg'):
        continue

    path = os.path.join('pdfs', 'page_images', file)
    _, img = data.transforms.presets.ssd.load_test(path, short=512)
    cv.imwrite(os.path.join('pdfs', 'scaled_images', file), img)


# ax = utils.viz.plot_bbox(img, bounding_boxes[0], scores[0],
#                          class_IDs[0], class_names=class_names, thresh=0.3)
# plt.savefig('myfig.png', dpi=500)
# plt.show()
