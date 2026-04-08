class MultimodalIdentifierExtractor < LlmService
  def extract_identifier_by_figure(figure)
    extract_identifier(figure.page.image.file_path, figure.type, [figure.x1, figure.y1, figure.x2, figure.y2])
  end

  def extract_identifier(image_path, figure_type, bounding_box = nil)
    image_data = File.read(image_path)
    image_base64 = Base64.strict_encode64(image_data)

    # Prepare the prompt based on figure type
    prompt = case figure_type
    when "Grave"
      "Identify the unique identifier (like 'G1', 'HROB 223', 'H 123') for this archaeological grave figure. The figure is located at coordinates [#{bounding_box&.join(", ")}] (xmin, ymin, xmax, ymax) on the page. Look for text near the figure that might contain its identifier. Return only the identifier, no additional text."
    when "StoneTool"
      "Identify the unique identifier (like 'ST1', 'Tool 5', 'Lithic 3') for this stone tool figure. The figure is located at coordinates [#{bounding_box&.join(", ")}] (xmin, ymin, xmax, ymax) on the page. Look for text near the figure that might contain its identifier. Return only the identifier, no additional text."
    when "Ceramic"
      "Identify the unique identifier (like 'C1', 'Vessel 5', 'Pot 3') for this ceramic figure. The figure is located at coordinates [#{bounding_box&.join(", ")}] (xmin, ymin, xmax, ymax) on the page. Look for text near the figure that might contain its identifier. Return only the identifier, no additional text."
    else
      "Identify the unique identifier for this archaeological figure. The figure is located at coordinates [#{bounding_box&.join(", ")}] (xmin, ymin, xmax, ymax) on the page. Look for text near the figure that might contain its identifier. Return only the identifier, no additional text."
    end

    # Make API request to Qwen 3.5 VL
    response = make_api_request(image_base64, prompt)

    # Extract and return the identifier
    extract_identifier_from_response(response)
  end

  private

  def extract_identifier_from_response(response)
    text = response["choices"][0]["message"]["content"]
    cleaned_text = text.strip.gsub(/\s+/, " ").strip
    cleaned_text.present? ? cleaned_text : nil
  end
end
