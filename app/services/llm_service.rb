class LlmService
  def self.configure
    yield self if block_given?
  end
end