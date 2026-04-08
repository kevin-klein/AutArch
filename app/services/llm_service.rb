class LlmService
  attr_reader :api_key, :base_url

  def initialize
    @api_key = ENV["LLM_API_KEY"]
    @base_url = ENV["LLM_VISION_BASE_URI"]
  end

  # Configuration block for setting up the service
  def self.configure
    yield self if block_given?
  end

  # Create embeddings for text using chunking
  def create_embedding(text, chunk_size: 512, overlap: 50)
    words = text.scan(/\S+/)
    all_embeddings = []

    i = 0
    while i < words.length
      chunk_words = words[i...(i + chunk_size)]
      chunk_text = chunk_words.join(" ")

      embedding = embed_chunk(chunk_text)
      all_embeddings << embedding if embedding.is_a?(Array)

      i += (chunk_size - overlap)
      break if i >= words.length || chunk_words.length < chunk_size
    end

    all_embeddings
  end

  # Make API request to LLM with optional image
  def make_api_request(prompt, image_base64: nil, context: nil, temperature: 1.0, system_prompt: nil)
    messages = build_messages(prompt, image_base64, system_prompt || default_system_prompt)
    
    payload = {
      model: "qwen 3.5",
      messages: messages,
      temperature: temperature
    }

    response = http_post("/chat/completions", payload)
    JSON.parse(response.body)
  rescue => e
    Rails.logger.error("LLM API error: #{e.message}")
    {"error" => e.message}
  end

  private

  def default_system_prompt
    {
      role: "system",
      content: [
        {
          type: "text",
          text: "You are a general-purpose assistant hosted entirely locally. You are not trained on internal data. Prioritize unbiased, factual accuracy: acknowledge uncertainties and ask clarifying questions when needed. Use only explicitly provided tools if they seem useful; otherwise, ignore them silently."
        }
      ]
    }
  end

  def embed_chunk(text)
    uri = URI(@base_url + "/embeddings")
    
    payload = { model: "local-model", input: text }.to_json
    response = http_post(uri, payload, content_type: "application/json")

    if response.code == "200"
      JSON.parse(response.body)["data"][0]["embedding"]
    else
      Rails.logger.error("Embedding API error at chunk: #{response.body}")
      nil
    end
  end

  def build_messages(prompt, image_base64, system_prompt)
    messages = [system_prompt]

    user_content = [{ type: "text", text: prompt }]

    if image_base64.present?
      user_content << {
        type: "image_url",
        image_url: { url: "data:image/jpeg;base64,#{image_base64}" }
      }
    end

    messages << { role: "user", content: user_content }
    messages
  end

  def http_post(path, payload, headers: {})
    uri = URI(@base_url + path)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.read_timeout = 300

    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Bearer #{@api_key}" if api_key.present?
    request["Content-Type"] = headers[:content_type] || "application/json"
    request.body = payload.is_a?(String) ? payload : payload.to_json

    http.request(request)
  end
end
