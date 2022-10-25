module AnalyzePdf
  extend self

  include PyCall::Import

  pyimport :layoutparser
  pyimport :pdf2image
  pyimport :io
  pyimport :PIL, as: 'pil'
  pyimport :cv2, as: 'cv'

  def slice
    PyCall::builtins.slice
  end

  def tuple
    PyCall::builtins.tuple
  end

  def model
    @model ||= layoutparser.models.Detectron2LayoutModel.new(
      'lp://PubLayNet/faster_rcnn_R_50_FPN_3x/config',
      extra_config: ["MODEL.ROI_HEADS.SCORE_THRESH_TEST", 0.8],
      label_map: { 0 => "Text", 1 => "Title", 2 => "List", 3 => "Table", 4 => "Figure" }
    )
  end

  def process_pdf(publication)
    Publication.transaction do
      images = pdf2image.convert_from_bytes(publication.pdf)

      pages = images.map.with_index do |image, index|
        f = io.BytesIO.new
        image.save(f, format: 'JPEG')

        db_image = Image.new(data: f.getvalue)
        page = publication.pages.create!(image: db_image, number: index)

        analyze_page(page, image)
      end
    end
  end

  def analyze_page(page, image)
    image = Numpy.array(image)
    layout = model.detect(image)

    figures = PyCall::enum(layout.__iter__)
      .select { |b| b.type =='Figure' }
    figure_blocks = layoutparser.Layout.new(figures.to_a)

    PyCall::enum(figure_blocks.__iter__).map do |block|
      part_image = block.crop_image(image)
      part_image_pil = pil.Image.fromarray(part_image)

      f = io.BytesIO.new
      part_image_pil.save(f, format: 'JPEG')

      page_image = page.page_images.create!(
        image: Image.new(data: f.getvalue)
      )

      search_figures(page_image, part_image)
    end
  end

  def extract_figures
    Page.includes(page_images: :figures).find_each do |page|
      page.page_images.each do |page_image|
        img = Vips::Image.new_from_buffer(page_image.image.data, '')

        page_image.figures.each do |figure|
          shape = Numpy.array(figure.shape)
          x, y, w, h = cv.boundingRect(shape)

          area = cv.contourArea(shape)

          if area > 30
            piece = img.crop(x, y, w, h)
            piece.write_to_file Rails.root.join('pdfs', 'figures', "#{figure.id}.jpg").to_s
          end
        end

        # points = Numpy.array(figure.shape)
        #
        # mask = Numpy.zeros(img.shape[slice.new(0, 2)], dtype: Numpy.uint8)
        # cv.drawContours(mask, [points], -1, tuple.new(255, 255, 255), -1, cv.LINE_AA)
        #
        # result = cv.bitwise_and(img, img, mask: mask)
        # rect = cv.boundingRect(points)
        # cropped = result[slice.new(rect[1], rect[1] + rect[3]), slice.new(rect[0], rect[0] + rect[2])]
        #
        # cv.imwrite(Rails.root.join('pdf', 'figures', "#{figure.id}.jpg").to_s, result)
      end
    end
  end
  def search_figures(page_image, image)
    gray = cv.cvtColor(image, cv.COLOR_BGR2GRAY)
    gray = cv.bitwise_not(gray)

    kernel = Numpy.ones(PyCall::Tuple.new(3, 3), Numpy.uint8)
    closing = cv.morphologyEx(gray, cv.MORPH_CLOSE, kernel, iterations: 1)

    dist = cv.distanceTransform(closing, cv.DIST_L2, 3)

    markers = Numpy.zeros(closing.shape, dtype: Numpy.int32)
    dist_8u = dist.astype('uint8')

    contours, _ = cv.findContours(dist_8u, cv.RETR_EXTERNAL, cv.CHAIN_APPROX_SIMPLE)

    db_entries = PyCall::enum(contours.__iter__).map do |contour|
      {
        page_image_id: page_image.id,
        shape: contour.tolist
      }
    end

    if db_entries.length > 0
      Figure.insert_all(db_entries)
    end
    
    nil
  end
end
