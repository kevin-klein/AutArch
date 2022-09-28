module AnalyzePdf
  extend self

  include PyCall::Import

  pyimport :layoutparser
  pyimport :pdf2image
  pyimport :io
  pyimport :PIL, as: 'pil'

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
      figure = block.pad(left: 5, right: 5, top: 5, bottom: 5).crop_image(image)
      figure = pil.Image.fromarray(figure)

      f = io.BytesIO.new
      figure.save(f, format: 'JPEG')

      page.figures.create!(
        image: Image.new(data: f.getvalue)
      )
    end
  end
end
