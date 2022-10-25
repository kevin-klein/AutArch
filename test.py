# import cv2 as cv
# import numpy as np
#
# image = cv.imread('example.PNG')
#
# image_gray = cv.cvtColor(image, cv.COLOR_BGR2GRAY)
# image_gray = cv.bitwise_not(image_gray)
#
# kernel = np.ones((3, 3),np.uint8)
# closing = cv.morphologyEx(image_gray, cv.MORPH_CLOSE, kernel, iterations = 1)
#
# dist = cv.distanceTransform(closing, cv.DIST_L2, 3)
# # ret, thresh = cv.threshold(image_gray, 220, 255, 0)
#
#
# markers = np.zeros(closing.shape, dtype=np.int32)
# dist_8u = dist.astype('uint8')
# contours, _ = cv.findContours(dist_8u, cv.RETR_EXTERNAL, cv.CHAIN_APPROX_SIMPLE)
# # for i in range(len(contours)):
# #     cv.drawContours(markers, contours, i, (i+1), -1)
#
# print(len(contours))
#
# cv.drawContours(image, contours, -1, (0, 0, 255), 1)
#
# # markers = cv.circle(markers, (15,15), 5, len(contours)+1, -1)
#
# # print(image_gray.shape)
# # wshed = cv.watershed(image, markers)
# # image[markers == -1] = [0,0,255]
#
# # cv.imshow('markers', markers.astype('uint8'))
# cv.imshow('watershed', image)

# cv.waitKey(0)


# import cv2 as cv
# import numpy as np
# import matplotlib.pyplot as plt
# # Feature set containing (x,y) values of 25 known/training data
# trainData = np.random.randint(0,100,(25,2)).astype(np.float32)
# # Label each one either Red or Blue with numbers 0 and 1
# responses = np.random.randint(0,2,(25,1)).astype(np.float32)
# # Take Red neighbours and plot them
# red = trainData[responses.ravel()==0]
# plt.scatter(red[:,0],red[:,1],80,'r','^')
# # Take Blue neighbours and plot them
# blue = trainData[responses.ravel()==1]
# plt.scatter(blue[:,0],blue[:,1],80,'b','s')
# # plt.show()
#
# newcomer = np.random.randint(0,100,(1,2)).astype(np.float32)
# plt.scatter(newcomer[:,0],newcomer[:,1],80,'g','o')
# knn = cv.ml.KNearest_create()
# knn.train(trainData, cv.ml.ROW_SAMPLE, responses)
# ret, results, neighbours ,dist = knn.findNearest(newcomer, 3)
# print( "result:  {}\n".format(results) )
# print( "neighbours:  {}\n".format(neighbours) )
# print( "distance:  {}\n".format(dist) )
# plt.show()

# import numpy as np
# import cv2 as cv
# from matplotlib import pyplot as plt
# X = np.random.randint(25,50,(25,2))
# Y = np.random.randint(60,85,(25,2))
# Z = np.vstack((X,Y))
# # convert to np.float32
# Z = np.float32(Z)
# # define criteria and apply kmeans()
# criteria = (cv.TERM_CRITERIA_EPS + cv.TERM_CRITERIA_MAX_ITER, 10, 1.0)
# ret,label,center=cv.kmeans(Z,2,None,criteria,10,cv.KMEANS_RANDOM_CENTERS)
# # Now separate the data, Note the flatten()
# A = Z[label.ravel()==0]
# B = Z[label.ravel()==1]
# # Plot the data
# plt.scatter(A[:,0],A[:,1])
# plt.scatter(B[:,0],B[:,1],c = 'r')
# plt.scatter(center[:,0],center[:,1],s = 80,c = 'y', marker = 's')
# plt.xlabel('Height'),plt.ylabel('Weight')
# plt.show()

# import os
#
# os.environ["CUDA_VISIBLE_DEVICES"]="-1"
#
# from tensorflow.keras import preprocessing
# from mrcnn.config import Config
# from mrcnn.model import MaskRCNN
# from mrcnn.utils import Dataset
# import tensorflow as tf
#
# import numpy as np
#
# # class that defines and loads the kangaroo dataset
# class DFGDataset(Dataset):
#     def load_mask(self, image_id):
#         mask = np.empty([0, 0, 0])
#         class_ids = np.empty([0], np.int32)
#         return mask, class_ids
#
#     # load the dataset definitions
#     def load_dataset(self, dataset_dir, is_train=True):
#         for class_id, folder in enumerate(os.listdir(dataset_dir)):
#             self.add_class('dataset', class_id, folder)
#
#             files = os.listdir(os.path.join(dataset_dir, folder))
#             if is_train:
#                 files = files[:int(len(files) * 0.6)]
#             else:
#                 files = files[int(len(files) * 0.4):]
#
#             for image in files:
#                 image_id = os.path.basename(image)
#                 path = os.path.join(dataset_dir, folder, image)
#                 self.add_image('dataset', image_id, path)
#
# train_set = DFGDataset()
# train_set.load_dataset('pdfs/figures', is_train=True)
# train_set.prepare()
#
# test_set = DFGDataset()
# test_set.load_dataset('pdfs/figures', is_train=False)
# test_set.prepare()
#
# class GraveConfig(Config):
#     # Give the configuration a recognizable name
#     NAME = "dfg"
#
#     # Train on 1 GPU and 8 images per GPU. We can put multiple images on each
#     # GPU because the images are small. Batch size is 8 (GPUs * images/GPU).
#     GPU_COUNT = 1
#     IMAGES_PER_GPU = 8
#
#     # Number of classes (including background)
#     NUM_CLASSES = 14  # background + 3 shapes
#
#     # Use small images for faster training. Set the limits of the small side
#     # the large side, and that determines the image shape.
#     IMAGE_MIN_DIM = 128
#     IMAGE_MAX_DIM = 512
#
#     # Use smaller anchors because our image and objects are small
#     RPN_ANCHOR_SCALES = (8, 16, 32, 64, 128)  # anchor side in pixels
#
#     # Reduce training ROIs per image because the images are small and have
#     # few objects. Aim to allow ROI sampling to pick 33% positive ROIs.
#     TRAIN_ROIS_PER_IMAGE = 32
#
#     # Use a small epoch since the data is simple
#     STEPS_PER_EPOCH = 100
#
#     # use small validation steps since the epoch is small
#     VALIDATION_STEPS = 5
#
# config = GraveConfig()
#
# model = MaskRCNN(mode='training', model_dir='./pdfs/model', config=config)
# model.load_weights(model.get_imagenet_weights(), by_name=True)
# model.train(train_set, test_set, learning_rate=config.LEARNING_RATE, epochs=5, layers='all')

# from keras.preprocessing import image
# import keras.utils
# from keras.applications.vgg16 import VGG16
# from keras.models import Model
# from keras.applications.vgg16 import preprocess_input
# import numpy as np
# from sklearn.cluster import AffinityPropagation
# import os, shutil, glob, os.path
# from PIL import Image as pil_image
# import cv2 as cv
# from sklearn.decomposition import PCA
# import sys
#
# image.LOAD_TRUNCATED_IMAGES = True
# model = VGG16(include_top=False)
#
#
# # Variables
# imdir = 'pdfs/figures'
# targetdir = "pdfs/clusters/"
# number_clusters = 16
#
# orb = cv.ORB_create(nfeatures=800, edgeThreshold=0, fastThreshold=0)
#
# # Loop over files and get features
# filelist = glob.glob(os.path.join(imdir, '*.jpg'))
# filelist.sort()
#
# featurelist = []
# for i, imagepath in enumerate(filelist):
#     img = keras.utils.load_img(imagepath, target_size=(224, 224))
#     img_data = keras.utils.img_to_array(img)
#
#     # kp, des = orb.detectAndCompute(img_data, None)
#     #
#     # a, b = des.shape
#     # # print(des.reshape(800 * 32).shape)
#     #
#     # des.resize((800 * 32, ))
#     # # print(des.shape)
#     #
#     # featurelist.append(des)
#
#     img_data = np.expand_dims(img_data, axis=0)
#     img_data = preprocess_input(img_data)
#     features = np.array(model.predict(img_data, verbose=0, use_multiprocessing=True))
#     featurelist.append(features.flatten())
#
# featurelist = np.array(featurelist)
#
# pca = PCA()
# pca.fit(featurelist)
# x = pca.transform(featurelist)
#
# # Clustering
# affprop = AffinityPropagation(affinity="euclidean", damping=0.5).fit(x)
#
# # Copy images renamed by cluster
# # Check if target dir exists
# try:
#     os.makedirs(targetdir)
# except OSError:
#     pass
#
# # Copy with cluster name
# for i, m in enumerate(affprop.labels_):
#     shutil.copy(filelist[i], targetdir + str(m) + "_" + str(i) + ".jpg")

import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers

batch_size = 32
image_size = (180, 180)

train_ds = tf.keras.preprocessing.image_dataset_from_directory(
    'pdfs/figures',
    validation_split=0.2,
    subset="training",
    image_size=image_size,
    seed=1337,
    batch_size=batch_size,
)
val_ds = tf.keras.preprocessing.image_dataset_from_directory(
    'pdfs/figures',
    validation_split=0.2,
    subset="validation",
    image_size=image_size,
    seed=1337,
    batch_size=batch_size,
)

train_ds = train_ds.prefetch(buffer_size=32)
val_ds = val_ds.prefetch(buffer_size=32)

data_augmentation = keras.Sequential(
    [
        layers.RandomFlip("horizontal"),
        layers.RandomRotation(0.1),
    ]
)

def make_model(input_shape, num_classes):
    inputs = keras.Input(shape=input_shape)
    # Image augmentation block
    x = data_augmentation(inputs)

    # Entry block
    x = layers.Rescaling(1.0 / 255)(x)
    x = layers.Conv2D(32, 3, strides=2, padding="same")(x)
    x = layers.BatchNormalization()(x)
    x = layers.Activation("relu")(x)

    x = layers.Conv2D(64, 3, padding="same")(x)
    x = layers.BatchNormalization()(x)
    x = layers.Activation("relu")(x)

    previous_block_activation = x  # Set aside residual

    for size in [128, 256, 512, 728]:
        x = layers.Activation("relu")(x)
        x = layers.SeparableConv2D(size, 3, padding="same")(x)
        x = layers.BatchNormalization()(x)

        x = layers.Activation("relu")(x)
        x = layers.SeparableConv2D(size, 3, padding="same")(x)
        x = layers.BatchNormalization()(x)

        x = layers.MaxPooling2D(3, strides=2, padding="same")(x)

        # Project residual
        residual = layers.Conv2D(size, 1, strides=2, padding="same")(
            previous_block_activation
        )
        x = layers.add([x, residual])  # Add back residual
        previous_block_activation = x  # Set aside next residual

    x = layers.SeparableConv2D(1024, 3, padding="same")(x)
    x = layers.BatchNormalization()(x)
    x = layers.Activation("relu")(x)

    x = layers.GlobalAveragePooling2D()(x)
    if num_classes == 2:
        activation = "sigmoid"
        units = 1
    else:
        activation = "softmax"
        units = num_classes

    x = layers.Dropout(0.5)(x)
    outputs = layers.Dense(units, activation=activation)(x)
    return keras.Model(inputs, outputs)


model = make_model(input_shape=image_size + (3,), num_classes=2)

epochs = 50

callbacks = [
    keras.callbacks.ModelCheckpoint("save_at_{epoch}.h5"),
]

model.compile(
    optimizer=keras.optimizers.Adam(1e-3),
    loss="binary_crossentropy",
    metrics=["accuracy"],
)
model.fit(
    train_ds, epochs=epochs, callbacks=callbacks, validation_data=val_ds,
)
