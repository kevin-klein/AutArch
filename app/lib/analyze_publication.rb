class AnalyzePublication
  def run(publication, site_id: nil)
    sleep(2.seconds)
    MessageBus.publish("/importprogress", "Converting pdf pages to images")
    path = create_temp_file(publication.pdf.download)
    images = pdf_to_images(path)

    page_number = 0
    figures = []
    image_count = page_count(path)
    images.each_with_index do |image, index|
      MessageBus.publish("/importprogress", {
        message: "Analyzing pages",
        progress: index.to_f / (image_count - 1)
      })
      page = publication.pages.find_or_initialize_by(number: page_number)
      page_number += 1

      image_data = image.write_to_buffer(".jpg")
      page.image = ::Image.create!(width: image.width, height: image.height)
      File.binwrite(page.image.file_path, image_data)
      # page.image.data.attach(io: StringIO.new(image_data), content_type: "image/jpg", filename: "#{publication.title}_#{index}.jpg")
      page.save!

      predictions = predict_boxes(image_data)

      predictions.each do |prediction|
        x1, y1, x2, y2 = prediction["box"]
        type_name = prediction["label"]
        type_name = "skeleton_figure" if type_name == "skeleton"
        probability = prediction["score"]
        if x1.to_i == x2.to_i || y1.to_i == y2.to_i || type_name.camelize.singularize == "St"
          next
        end

        cls_name = type_name.camelize.singularize
        begin Module.const_get(cls_name)
              figure = page.figures.create!(x1: x1, y1: y1, x2: x2, y2: y2, probability: probability, type: type_name.camelize.singularize, publication: publication)
              figures << figure
              
              # Extract text summary for this figure
              extract_text_summary(figure)
        rescue NameError
          Rails.logger.warn("Class #{cls_name} not found, discarding object")
        end
      end
    end

    Page.transaction do
      # MessageBus.publish("/importprogress", "Analyzing Text")
      # BuildText.new.run(publication)
      MessageBus.publish("/importprogress", "Grouping Figures to Graves")
      CreateGraves.new.run(publication.pages)
      CreateLithics.new.run(publication.pages)
      MessageBus.publish("/importprogress", "Creating Orientations of Bounding Boxes")
      GraveAngles.new.run(figures.select { _1.is_a?(Arrow) })
      MessageBus.publish("/importprogress", "Measuring Sizes")
      GraveSize.new.run(figures)
      figures.each do |figure|
        AnalyzeContour.new.run(figure)
      end
      MessageBus.publish("/importprogress", "Analyzing Scales")
      AnalyzeScales.new.run(figures)
      MessageBus.publish("/importprogress", "Done. Please proceed to Graves in the NavBar.")
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
    file = HTTP::FormData::File.new io, filename: "page.jpg"
    response = HTTP.post(ENV["ML_SERVICE_URL"], form: {
      image: file
    })

    response.parse["predictions"]
  end

  def page_count(path)
    PDF::Reader.open(path, &:page_count)
  end

  private

  def extract_text_summary(figure)
    # Extract text summary using multimodal LLM
    extractor = TextSummaryExtractor.new
    summary = extractor.extract_summary(figure, figure.publication_id)
    
    # Update the figure with the extracted summary
    if summary.present?
      figure.update(text_summary: summary)
      Rails.logger.info("Extracted text summary for figure #{figure.id} (#{figure.type})")
    else
      # Try one more time if self-validation failed
      Rails.logger.warn("Failed to extract text summary for figure #{figure.id} (#{figure.type}) - trying again")
      
      # Try again with a different approach
      summary = extractor.extract_summary_with_retry(figure, figure.publication_id)
      
      if summary.present?
        figure.update(text_summary: summary)
        Rails.logger.info("Successfully extracted text summary for figure #{figure.id} (#{figure.type}) after retry")
      else
        Rails.logger.warn("Failed to extract text summary for figure #{figure.id} (#{figure.type}) after retry")
      end
    end
  end

  def extract_text_summary_with_retry(figure)
    # Extract text summary using multimodal LLM with retry logic
    extractor = TextSummaryExtractor.new
    summary = extractor.extract_summary_with_retry(figure, figure.publication_id)
    
    # Update the figure with the extracted summary
    if summary.present?
      figure.update(text_summary: summary)
      Rails.logger.info("Extracted text summary for figure #{figure.id} (#{figure.type}) with retry")
    else
      Rails.logger.warn("Failed to extract text summary for figure #{figure.id} (#{figure.type}) with retry")
    end
  end

  def get_figure_image_path(figure)
    # Get the image path for the figure
    if figure.page && figure.page.image && figure.page.image.data.attached?
      # Get the path to the image file
      figure.page.image.data.service_url
    else
      # Try to get the image from the figure's bounding box
      nil
    end
  end
end
