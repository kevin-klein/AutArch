import dfg
import cv2 as cv
import layoutparser as lp
import numpy as np

if __name__ == '__main__':
    dfg.process_pdf_folder('pdfs', dfg.render_to_image)
    # dfg.render_to_image('pdfs/Dobes et al. 2011 Vlineves.pdf', 'pdfs/Dobeš & Limburský_2013_Vlineves-KSK')
    # image = cv.imread('pdfs/Dobes et al. 2011 Vlineves/09cb79cf-df6b-48fe-a0ac-9b8832a2c2f9-06.ppm')
    # dfg.process_image(image)
    # image = cv.imread("pdfs/Dobes et al. 2011 Vlineves/09cb79cf-df6b-48fe-a0ac-9b8832a2c2f9-06.ppm")
    # image = image[..., ::-1]
    # model = lp.models.Detectron2LayoutModel('lp://PubLayNet/faster_rcnn_R_50_FPN_3x/config',
    #                              extra_config=["MODEL.ROI_HEADS.SCORE_THRESH_TEST", 0.8],
    #                              label_map={0: "Text", 1: "Title", 2: "List", 3:"Table", 4:"Figure"})
    # layout = model.detect(image)
    # figure_blocks = lp.Layout([b for b in layout if b.type=='Figure'])

    # image = lp.draw_box(image, figure_blocks, box_width=3)
    # cv.imwrite('parser.jpg', np.array(image))
