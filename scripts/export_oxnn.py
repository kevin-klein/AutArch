from gluoncv.model_zoo import get_model
import mxnet as mx
from mxnet import gluon
import mxnet.contrib.onnx as onnx_mxnet
import mxnet.ndarray as nd
import numpy as np

from gluoncv.model_zoo import get_model
import mxnet as mx
from mxnet import gluon
import mxnet.ndarray as nd

# net_name = 'resnet50_v1'
#
# ctx = [mx.gpu(0)]
#
# net = gluon.nn.SymbolBlock.imports("dfg-symbol.json", ['data'], "dfg-0000.params", ctx=ctx)
#
# print(get_layer_output(net))

sym = 'dfg-symbol.json'
params = 'dfg-0000.params'

input_shape = [(1,3,224,224)]
onnx_file = './mxnet_exported_resnet18.onnx'

converted_model_path = onnx_mxnet.export_model(sym, params, input_shape, np.float32, onnx_file)
