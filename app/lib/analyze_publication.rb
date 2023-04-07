class AnalyzePublication
  def run(publication, site_id: nil)
    Page.transaction do
      images = pdf_to_images(publication.pdf)

      page_number = 0
      figures = []
      images.each do |image|
        page = publication.pages.find_or_initialize_by(number: page_number)
        page_number += 1

        image_data = image.write_to_buffer('.jpg')
        page.image = Image.create!(data: image_data, width: image.width, height: image.height)
        page.save!

        predictions = predict_boxes(image_data)

        predictions.each do |prediction|
          x1, y1, x2, y2 = prediction['box']
          type_name = prediction['label']
          type_name = 'skeleton_figure' if type_name == 'skeleton'
          propability = prediction['score']
          next if propability < 0.8

          figures << page.figures.create!({ x1: x1, y1: y1, x2: x2, y2: y2, type: type_name.camelize.singularize })
        end
      end

      CreateGraves.new.run(publication.pages)
      GraveAngles.new.run(figures.select { _1.is_a?(Arrow) })
      GraveSize.new.run(figures)

      # publication.graves.update_all(site_id: site_id)
    end
  end

  def pdf_to_images(pdf)
    @file = Tempfile.new(SecureRandom.hex, binmode: true)
    @file.write(pdf)
    @file.flush

    path = @file.path
    page_count = page_count(path)
    (0..page_count - 1).map do |page|
      Vips::Image.pdfload(path, page: page, dpi: 300).flatten
    end
  end

  def predict_boxes(image)
    io = StringIO.new(image)
    file = HTTP::FormData::File.new io, filename: 'page.jpg'
    response = HTTP.post('http://localhost:8080', form: {
                           image: file
                         })

    response.parse['predictions']
  end

  def page_count(path)
    PDF::Reader.open(path, &:page_count)
  end
end
