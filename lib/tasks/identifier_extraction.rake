namespace :identifier do
  desc "Extract identifiers for all graves using multimodal LLM"
  task extract_graves: :environment do
    puts "Starting identifier extraction for all graves..."
    
    graves = Grave.where(identifier: nil)
    total = graves.count
    processed = 0
    
    graves.find_each do |grave|
      # Get the image for this grave
      image_path = get_grave_image_path(grave)
      
      if image_path && File.exist?(image_path)
        # Get bounding box coordinates
        bounding_box = [grave.x1, grave.y1, grave.x2, grave.y2]
        
        # Extract identifier using multimodal LLM
        extractor = MultimodalIdentifierExtractor.new
        identifier = extractor.extract_identifier(image_path, 'Grave', bounding_box)
        
        # Update the grave with the extracted identifier
        if identifier.present?
          grave.update(identifier: identifier)
          puts "Extracted identifier '#{identifier}' for grave #{grave.id}"
        else
          puts "Failed to extract identifier for grave #{grave.id}"
        end
      else
        puts "Could not find image for grave #{grave.id}"
      end
      
      processed += 1
      puts "Progress: #{processed}/#{total} graves processed"
    end
    
    puts "Identifier extraction for graves completed."
  end
  
  desc "Extract identifiers for all size figures using multimodal LLM"
  task extract_size_figures: :environment do
    puts "Starting identifier extraction for all size figures..."
    
    size_figures = SizeFigure.where(identifier: nil)
    total = size_figures.count
    processed = 0
    
    size_figures.find_each do |figure|
      # Get the image for this figure
      image_path = get_figure_image_path(figure)
      
      if image_path && File.exist?(image_path)
        # Get bounding box coordinates
        bounding_box = [figure.x1, figure.y1, figure.x2, figure.y2]
        
        # Extract identifier using multimodal LLM
        extractor = MultimodalIdentifierExtractor.new
        identifier = extractor.extract_identifier(image_path, figure.type, bounding_box)
        
        # Update the figure with the extracted identifier
        if identifier.present?
          figure.update(identifier: identifier)
          puts "Extracted identifier '#{identifier}' for figure #{figure.id} (#{figure.type})"
        else
          puts "Failed to extract identifier for figure #{figure.id} (#{figure.type})"
        end
      else
        puts "Could not find image for figure #{figure.id} (#{figure.type})"
      end
      
      processed += 1
      puts "Progress: #{processed}/#{total} figures processed"
    end
    
    puts "Identifier extraction for size figures completed."
  end
  
  private
  
  def get_grave_image_path(grave)
    # Get the image path for the grave
    if grave.page && grave.page.image && grave.page.image.data.attached?
      # Get the path to the image file
      grave.page.image.data.service_url
    else
      # Try to get the image from the grave's bounding box
      nil
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