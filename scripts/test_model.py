from gluoncv.model_zoo import get_model
import mxnet as mx
from mxnet import gluon
import pandas as pd
import mxnet.ndarray as nd

net_name = 'resnet50_v1'

ctx = [mx.gpu(0)]

net = gluon.nn.SymbolBlock.imports("dfg-symbol.json", ['data'], "dfg-0000.params", ctx=ctx)

from gluoncv import model_zoo, data, utils
from matplotlib import pyplot as plt
import os

table_data = []

for file in os.listdir('pdfs/page_images/'):
    if not file.endswith('.jpg'):
        continue

    path = os.path.join('pdfs', 'page_images', file)
    x, img = data.transforms.presets.ssd.load_test(path, short=512)
    x = x.copyto(mx.gpu(0))
    class_IDs, scores, bounding_boxes = net(x)

    class_names = ['grave', 'grave_cross_section', 'goods', 'arrow_up', 'arrow_left', 'arrow_down', 'arrow_right', 'scale', 'grave_photo', 'grave_photo_left_side', 'grave_photo_right_side', 'skeleton', 'skeleton_left_side', 'skeleton_right_side', 'map', 'skeleton_photo', 'skeleton_photo_left_side', 'skeleton_photo_right_side', 'skull', 'skull_photo']
    bounding_boxes = bounding_boxes[0]
    scores = scores[0]
    class_IDs = class_IDs[0]

    for index in range(len(class_IDs)):
        class_ID = int(class_IDs[index].asscalar())
        score = scores[index].asscalar()
        box = bounding_boxes[index]

        if score < 0.1:
            continue

        x1, y1, x2, y2 = box

        table_data.append({
            'file': file,
            'class': class_names[class_ID],
            'x1': x1.asscalar(),
            'y1': y1.asscalar(),
            'x2': x2.asscalar(),
            'y2': y2.asscalar(),
            'score': score
        })

frame = pd.DataFrame(table_data)
frame.to_csv('graves.csv')

# ax = utils.viz.plot_bbox(img, bounding_boxes[0], scores[0],
#                          class_IDs[0], class_names=class_names, thresh=0.3)
# plt.savefig('myfig.png', dpi=500)
# plt.show()
