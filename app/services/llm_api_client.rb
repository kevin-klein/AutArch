class LlmApiClient
  include Concurrent::Actor::Base
  include Concurrent::Actor::ActorProtocol

  def initialize(config)
    @config = config
    @client = OpenAI::Client.new(
      api_key: config[:api_key],
      timeout: config[:timeout] || 10.seconds
    )
    @last_response = nil
    @failure_count = 0
    @max_retries = config[:max_retries] || 3
    @rate_limit = config[:rate_limit] || 60 # requests per minute
    @last_request_time = 0
    @retry_count = 0
  end

  # Actor message: execute_lambda
  # actor_message :execute_lambda, lambda => result
  def execute_lambda(lambda)
    self
    @retry_count = 0
    @failure_count = 0
    result = nil
    begin
      # Rate limiting
      if Time.now - @last_request_time < (1/60.0)
        raise "Rate limit exceeded"
      end
      @last_request_time = Time.now

      # Execute lambda with timeout
      result = @client.execute(lambda, @config[:timeout] || 30.seconds)
      @last_response = result
    rescue => e
      @failure_count += 1
      if @failure_count <= @max_retries
        sleep 0.5
        retry
      else
        raise "Max retries exceeded: #{e.message}"
      end
    end
    @retry_count = 0
    @failure_count = 0
    result
  end

  # Actor message: get_last_response
  # actor_message :get_last_response => response
  def get_last_response
    self
    @last_response
  end

  def cleanup
    self
    @client.disconnect if @client.connected?
  end
end

# Initialize client with config
LlmApiClient.configure do |client|
  client.configure do |config|
    config.api_key = ENV['OPENAI_API_KEY']
    config.timeout = ENV['LLM_TIMEOUT'] ? ENV['LLM_TIMEOUT'].to_i : 10
    config.max_retries = ENV['LLM_MAX_RETRIES'] ? ENV['LLM_MAX_RETRIES'].to_i : 3
    config.rate_limit = ENV['LLM_RATE_LIMIT'] ? ENV['LLM_RATE_LIMIT'].to_i : 60
  end
end

# Example usage
# client.execute_lambda do |lambda|
#   lambda.call("Hello")
# end

end
