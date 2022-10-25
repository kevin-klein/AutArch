from gluoncv.model_zoo import get_model
import mxnet as mx
from mxnet import gluon
import mxnet.ndarray as nd

net_name = 'resnet50_v1'

ctx = [mx.gpu(0)]

net = gluon.nn.SymbolBlock.imports("dfg-symbol.json", ['data'], "dfg-0000.params", ctx=ctx)

from gluoncv import model_zoo, data, utils
from matplotlib import pyplot as plt

path = 'E:\\dfg\\pdfs\\VOC2018\\JPEGImages\\Limbursky et al. 2013-4.jpg'
x, img = data.transforms.presets.ssd.load_test(path, short=512)
print('Shape of pre-processed image:', x.shape)
x = x.copyto(mx.gpu(0))
class_IDs, scores, bounding_boxes = net(x)

class_names = ['grave', 'grave_cross_section', 'goods', 'arrow', 'scale', 'grave_photo', 'skeleton', 'map', 'skeleton_photo']

ax = utils.viz.plot_bbox(img, bounding_boxes[0], scores[0],
                         class_IDs[0], class_names=class_names, thresh=0.3)
plt.savefig('myfig.png', dpi=500)
plt.show()
