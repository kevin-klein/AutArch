from gluoncv.model_zoo import get_model
import mxnet as mx
from mxnet import gluon
import mxnet.contrib.onnx as onnx_mxnet
import mxnet.ndarray as nd
import numpy as np

# from gluoncv.model_zoo import get_model
# import mxnet as mx
# from mxnet import gluon
# import mxnet.ndarray as nd
#
# net_name = 'resnet50_v1'
#
# ctx = [mx.cpu(0)]
#
# net = gluon.nn.SymbolBlock.imports("dfg-symbol.json", ['data'], "dfg-0000.params", ctx=ctx)

sym = 'dfg-symbol.json'
params = 'dfg-0000.params'

in_shape = [(1, 3, 724, 512)]
onnx_file = './dfg_ssd.onnx'

converted_model_path = onnx_mxnet.export_model(sym, params, in_shapes=in_shape, onnx_file_path=onnx_file)
