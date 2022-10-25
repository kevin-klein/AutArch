from gluoncv.data import VOCDetection

class VOCLike(VOCDetection):
    CLASSES = ['grave', 'grave_cross_section', 'goods', 'arrow', 'scale', 'grave_photo', 'skeleton', 'map', 'skeleton_photo']
    def __init__(self, root='pdfs\\VOC2018', splits=[], transform=None, index_map=None, preload_label=True):
        super(VOCLike, self).__init__(root, splits, transform, index_map, preload_label)

train_dataset = VOCLike(
    splits=[('', 'train')])

print(train_dataset.classes)
