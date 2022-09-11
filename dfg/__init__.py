import fitz
import io
import os
import sys
from PIL import Image
from multiprocessing import Pool, TimeoutError
from pdf2image import convert_from_path, convert_from_bytes
import cv2 as cv
import numpy as np
import layoutparser as lp

model = lp.models.Detectron2LayoutModel('lp://PubLayNet/mask_rcnn_X_101_32x8d_FPN_3x/config',
                             extra_config=["MODEL.ROI_HEADS.SCORE_THRESH_TEST", 0.8],
                             label_map={0: "Text", 1: "Title", 2: "List", 3:"Table", 4:"Figure"})

def get_images(doc):
    result = []
    for page in doc:
        image_list = page.get_images(full=True)
        for image in image_list:
            (xref, smask, width, height, bpc, colorspace, alt_colorspace, name, filter, referencer) = image

            img_data = doc.extract_image(xref)
            img_data['name'] = name
            yield img_data

def extract_images(pdf, output):
    with fitz.open(pdf) as doc:
        images = get_images(doc)
        save_images(images, output)

def save_images(images, output):
    for image in images:
        with open(os.path.join(output, f"{image['name']}.{image['ext']}"), 'wb') as image_file:
            image_file.write(image['image'])

def render_to_image(pdf, output):
    images = convert_from_path(pdf) #, output_folder=output, fmt='jpeg')

    for idx, image in enumerate(images):
        process_image(np.array(image), output, idx)

def process_image(image, output, image_idx):
    layout = model.detect(image)
    figure_blocks = lp.Layout([b for b in layout if b.type=='Figure'])
    print(len(figure_blocks))
    for idx, block in enumerate(figure_blocks):
        segment_image = block.pad(left=5, right=5, top=5, bottom=5).crop_image(image)
        print(os.path.join(output, str(idx) + '_' + str(image_idx) + '.jpg'))
        cv.imwrite(os.path.join(output, str(idx) + '_' + str(image_idx) + '.jpg'), segment_image)

def process_pdf_folder(folder, f):
    files = os.listdir(folder)
    files = filter(lambda f: f.endswith('.pdf'), files)

    # pool = Pool()
    for file in files:
        output = os.path.join(folder, os.path.splitext(file)[0])
        if not os.path.exists(output):
            os.mkdir(output)

        f(os.path.join(folder, file), output)
        # pool.apply_async(f, (os.path.join(folder, file), output))
    # pool.close()
    # pool.join()
