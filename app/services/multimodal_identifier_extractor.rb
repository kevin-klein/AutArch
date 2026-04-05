class MultimodalIdentifierExtractor
  def initialize
    @api_key = ENV['QWEN_API_KEY']
    @base_url = ENV['QWEN_API_URL'] || 'https://dashscope.aliyuncs.com/api/v1/services/qwen-vl-plus'
  end

  def extract_identifier(image_path, figure_type, bounding_box = nil)
    # Convert image to base64 for API request
    image_data = File.read(image_path)
    image_base64 = Base64.encode64(image_data)
    
    # Prepare the prompt based on figure type
    prompt = case figure_type
             when 'Grave'
               "Identify the unique identifier (like 'G1', 'Grave 5', 'Tomb 3') for this archaeological grave figure. The figure is located at coordinates [#{bounding_box&.join(', ')}] (xmin, ymin, xmax, ymax) on the page. Look for text near the figure that might contain its identifier. Return only the identifier, no additional text."
             when 'StoneTool'
               "Identify the unique identifier (like 'ST1', 'Tool 5', 'Lithic 3') for this stone tool figure. The figure is located at coordinates [#{bounding_box&.join(', ')}] (xmin, ymin, xmax, ymax) on the page. Look for text near the figure that might contain its identifier. Return only the identifier, no additional text."
             when 'Ceramic'
               "Identify the unique identifier (like 'C1', 'Vessel 5', 'Pot 3') for this ceramic figure. The figure is located at coordinates [#{bounding_box&.join(', ')}] (xmin, ymin, xmax, ymax) on the page. Look for text near the figure that might contain its identifier. Return only the identifier, no additional text."
             else
               "Identify the unique identifier for this archaeological figure. The figure is located at coordinates [#{bounding_box&.join(', ')}] (xmin, ymin, xmax, ymax) on the page. Look for text near the figure that might contain its identifier. Return only the identifier, no additional text."
             end
    
    # Make API request to Qwen 3.5 VL
    response = make_api_request(image_base64, prompt)
    
    # Extract and return the identifier
    extract_identifier_from_response(response)
  end

  private

  def make_api_request(image_base64, prompt)
    uri = URI(@base_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Bearer #{@api_key}"
    request['Content-Type'] = 'application/json'
    
    request.body = {
      model: 'qwen-vl-plus',
      messages: [
        {
          role: 'user',
          content: [
            { image: "data:image/jpeg;base64,#{image_base64}" },
            { text: prompt }
          ]
        }
      ],
      temperature: 0.1,
      max_tokens: 100
    }.to_json
    
    response = http.request(request)
    JSON.parse(response.body)
  rescue => e
    Rails.logger.error("Qwen API error: #{e.message}")
    { 'error' => e.message }
  end

  def extract_identifier_from_response(response)
    # Extract the identifier from the response
    if response['output'] && response['output']['choices'] && response['output']['choices'].any?
      text = response['output']['choices'][0]['message']['content']
      # Clean up the response to extract just the identifier
      cleaned_text = text.strip.gsub(/[^a-zA-Z0-9\-_]/, '').gsub(/\s+/, ' ').strip
      cleaned_text.present? ? cleaned_text : nil
    else
      nil
    end
  end
end