LlmService.configure do |config|
  # Configure your LLM service here
  config.api_key = ENV['QWEN_API_KEY']
  config.base_url = ENV['QWEN_API_URL'] || 'https://dashscope.aliyuncs.com/api/v1/services/qwen-vl-plus'
end