from gluoncv.model_zoo import get_model
import mxnet as mx
from mxnet import gluon
import mxnet.ndarray as nd
from mxnet import nd, autograd, gluon

net_name = 'resnet50_v1'

ctx = [mx.gpu(0)]

gluon.nn.SymbolBlock.imports("dfg-symbol.json", ['data'], "dfg-0000.params", ctx=ctx)

net.load_parameters('C:\\Users\\Kevin\\.mxnet\\models\\resnet50_v1-cc729d95.params', ctx=ctx)
net.collect_params().reset_ctx(ctx=ctx)

net.export('dfg')
