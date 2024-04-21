class AnalyzePublication
  def run(publication, site_id: nil)
    sleep(2.seconds)
    MessageBus.publish('/importprogress', 'Converting pdf pages to images')
    path = create_temp_file(publication.pdf.download)
    images = pdf_to_images(path)

    page_number = 0
    figures = []
    image_count = page_count(path)
    images.each_with_index do |image, index|
      MessageBus.publish('/importprogress', {
        message: 'Analyzing pages',
        progress: index.to_f / (image_count-1)
      })
      page = publication.pages.find_or_initialize_by(number: page_number)
      page_number += 1

      image_data = image.write_to_buffer('.jpg')
      page.image = Image.create!(width: image.width, height: image.height)
      page.image.data.attach(io: StringIO.new(image_data), content_type: 'image/jpg', filename: "#{publication.title}_#{index}.jpg")
      page.save!

      predictions = predict_boxes(image_data)

      predictions.each do |prediction|
        x1, y1, x2, y2 = prediction['box']
        type_name = prediction['label']
        type_name = 'skeleton_figure' if type_name == 'skeleton'
        probability = prediction['score']
        if x1.to_i == x2.to_i || y1.to_i == y2.to_i || type_name.camelize.singularize == 'St'
          next
        end

        figure = page.figures.create!( x1: x1, y1: y1, x2: x2, y2: y2, probability: probability, type: type_name.camelize.singularize, publication: publication)
        figures << figure
      end
    end

    Page.transaction do
      BuildText.new.run(publication)
      MessageBus.publish('/importprogress', 'Grouping Figures to Graves')
      CreateGraves.new.run(publication.pages)
      CreateLithics.new.run(publication.pages)
      MessageBus.publish('/importprogress', 'Creating Orientations of Bounding Boxes')
      GraveAngles.new.run(figures.select { _1.is_a?(Arrow) })
      MessageBus.publish('/importprogress', 'Measuring Sizes')
      GraveSize.new.run(figures)
      MessageBus.publish('/importprogress', 'Analyzing Scales')
      AnalyzeScales.new.run(figures)
      MessageBus.publish('/importprogress', 'Done. Please proceed to Graves in the NavBar.')
      # publication.graves.update_all(site_id: site_id)
    end
  end

  def create_temp_file(pdf)
    @file = Tempfile.new(SecureRandom.hex, binmode: true)
    @file.write(pdf)
    @file.flush
    @file.path
  end

  def pdf_to_images(path)
    page_count = page_count(path)
    (0..page_count - 1).lazy.map do |page|
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
