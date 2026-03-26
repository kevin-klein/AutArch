module CosineSimilarity
  # Calculate cosine similarity between two vectors
  # Both vectors should be arrays of numbers
  def self.similarity(vec1, vec2)
    return 0.0 if vec1.nil? || vec2.nil? || vec1.empty? || vec2.empty?

    dot_product = 0.0
    norm1 = 0.0
    norm2 = 0.0

    vec1.each_with_index do |val, i|
      dot_product += val * vec2[i] if vec2[i]
      norm1 += val * val
      norm2 += vec2[i] * vec2[i] if vec2[i]
    end

    return 0.0 if norm1 == 0.0 || norm2 == 0.0

    dot_product / (Math.sqrt(norm1) * Math.sqrt(norm2))
  end
end