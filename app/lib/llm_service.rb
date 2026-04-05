class LlmService
  def self.summarize(text, image_data: nil)
    payload = { text: text }
    payload[:image] = image_data if image_data
    
    response = HTTParty.post(
      "#{LlmService.config.base_url}/summarize",
      headers: { "Content-Type" => "application/json" },
      body: payload.to_json,
      timeout: LlmService.config.timeout
    )

    if response.success?
      response.parsed_response["summary"]
    else
      "Error: #{response.body}"
    end
  end

  def self.extract_info(text, image_data: nil)
    payload = { text: text }
    payload[:image] = image_data if image_data
    
    response = HTTParty.post(
      "#{LlmService.config.base_url}/extract_info",
      headers: { "Content-Type" => "application/json" },
      body: payload.to_json,
      timeout: LlmService.config.timeout
    )

    if response.success?
      response.parsed_response["extracted_info"]
    else
      "Error: #{response.body}"
    end
  end
end