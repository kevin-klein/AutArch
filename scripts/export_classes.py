from gluoncv.data import VOCDetection

class VOCLike(VOCDetection):
    CLASSES = [
        'grave',
        'grave_cross_section',
        'goods',
        'arrow_up',
        'arrow_left',
        'arrow_down',
        'arrow_right',
        'scale',
        'grave_photo',
        'grave_photo_left_side',
        'grave_photo_right_side',
        'skeleton',
        'skeleton_left_side',
        'skeleton_right_side',
        'map',
        'skeleton_photo',
        'skeleton_photo_left_side',
        'skeleton_photo_right_side',
        'skull',
        'skull_photo'
    ]
    def __init__(self, root='pdfs\\VOC2018', splits=[], transform=None, index_map=None, preload_label=True):
        super(VOCLike, self).__init__(root, splits, transform, index_map, preload_label)

train_dataset = VOCLike(
    splits=[('', 'train')])

print(train_dataset.classes)
