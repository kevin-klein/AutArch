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
from pyrsistent import PRecord, field, v

# ids are optional due to instanciation

class Publication(PRecord):
    id = field(type=(int, type(None)))
    file = field(type=str)
    author = field(type=(str, type(None)))
    title = field(type=(str, type(None)))
    pages = field()

class Page(PRecord):
    id = field(type=(int, type(None)))
    number = field(type=int)
    image_file = field(type=str)
    publicaton_id = field(type=(int, type(None)))

class PageImage(PRecord):
    id = field(type=(int, type(None)))


def list_pdfs():
    files = os.listdir('pdfs')

    for file in files:
        if not f.endswith('.pdf'):
            continue

        yield file

# true pdf image extraction

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

# image rendering and layout parser extraction

model = lp.models.Detectron2LayoutModel('lp://PubLayNet/mask_rcnn_X_101_32x8d_FPN_3x/config',
                             extra_config=["MODEL.ROI_HEADS.SCORE_THRESH_TEST", 0.8],
                             label_map={0: "Text", 1: "Title", 2: "List", 3:"Table", 4:"Figure"})

def persist_page_images(images, output):
    for idx, image in enumerate(images):
        image = np.array(image)
        path = os.path.join(output, f'page_{idx}.jpg')
        cv.imwrite(image, path)
        yield (idx, f'page_{idx}.jpg')

def extract_image_from_page(db, pdf, output):
    pdf_name = os.path.splitext(pdf['file'])[0]
    images = convert_from_path(pdf['full_path_file'])
    image_names = persist_page_images(images)
    image_paths = map(lambda name: os.path.join(pdf_name, name), image_names)

    publication = Publication(file=pdf)
    pages = v(Page(number=idx, image_file=image) for idx, image in enumerate(image_paths))

    for idx, page in enumerate(pages):
        page_images = process_image(page, np.array(image), output, idx)
        page_images = map(lambda image: os.path.join(pdf_name, image), page_images)

        db.save_images(db, page, page_images)

def process_image(page, image, output, image_idx):
    layout = model.detect(image)
    figure_blocks = lp.Layout([b for b in layout if b.type=='Figure'])
    for idx, block in enumerate(figure_blocks):
        segment_image = block.pad(left=5, right=5, top=5, bottom=5).crop_image(image)
        image_path = str(idx) + '_' + str(image_idx) + '.jpg'
        cv.imwrite(os.path.join(output, image_path), segment_image)
        yield image_path

def process_pdf_folder(db, folder, f):
    pdfs = list_pdfs()
    pdfs = db.save_publications(db, pdfs)

    for pdf in pdfs:
        output = os.path.join(os.getenv('PDF_ROOT'), os.path.splitext(pdf['file'])[0])
        if not os.path.exists(output):
            os.mkdir(output)
        pdf['full_path_file'] = os.path.join(os.getenv('PDF_ROOT'), file)

        f(db, pdf, output)
