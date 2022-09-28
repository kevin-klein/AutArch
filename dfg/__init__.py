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
from pyrsistent import PRecord, field, pvector

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
    page_image = field()
    publicaton_id = field(type=(int, type(None)))
    images = field()

class PageImage(PRecord):
    id = field(type=(int, type(None)))
    image = field()

class Shape(PRecord):
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

def extract_image_from_page(pdf, output):
    pdf_name = os.path.splitext(os.path.basename(pdf))[0]
    images = convert_from_path(pdf)

    pages = pvector(Page(number=idx, page_image=np.array(image)) for idx, image in enumerate(images))

    e = pages.evolver()
    for idx, page in enumerate(pages[:3]):
        page_images = process_image(page, page.get('page_image'), output, idx)

        e[idx] = page.set('images', pvector(PageImage(image=image) for image in page_images))

    pages = e.persistent()

    publication = Publication(file=pdf, pages=pages)
    return publication


def process_image(page, image, output, image_idx):
    layout = model.detect(image)
    figure_blocks = lp.Layout([b for b in layout if b.type=='Figure'])
    for idx, block in enumerate(figure_blocks):
        segment_image = block.pad(left=5, right=5, top=5, bottom=5).crop_image(image)
        yield segment_image

def process_pdf_folder(folder, f):
    pdfs = list_pdfs()

    for pdf in pdfs:
        output = os.path.join(os.getenv('PDF_ROOT'), os.path.splitext(pdf['file'])[0])
        if not os.path.exists(output):
            os.mkdir(output)
        pdf['full_path_file'] = os.path.join(os.getenv('PDF_ROOT'), file)

        f(pdf, output)
