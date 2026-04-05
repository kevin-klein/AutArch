class FigureText < ApplicationRecord
  belongs_to :figure
  
  # JSON columns for flexible storage
  # ocr_text: Raw OCR output
  # extracted_dimensions: Array of dimension objects
  # extracted_description: String description of what figure shows
  # extracted_summary: String summary of key features
  # key_phrases: Array of key archaeological terms
  # raw_text: Complete extracted text
  
  # Before saving, parse and structure the data
  def parse_ocr_text(ocr_text)
    # Extract dimensions
    self.extracted_dimensions = extract_dimensions(ocr_text)
    
    # Extract description
    self.extracted_description = extract_description(ocr_text)
    
    # Extract summary
    self.extracted_summary = extract_summary(ocr_text)
    
    # Extract key phrases
    self.key_phrases = extract_key_phrases(ocr_text)
    
    # Store raw OCR text
    self.ocr_text = ocr_text
  end
  
  # Extract dimensions from text
  def extract_dimensions(text)
    dimensions = []
    text.scan(/(\d+\.?\d*)\s*(cm|mm|in|m)?/i) do |match|
      value = match[0].to_f
      unit = match[1]&.downcase&.to_sym || :cm
      dimensions << { value: value, unit: unit }
    end
    dimensions
  end
  
  # Extract description of what figure shows
  def extract_description(text)
    # Look for patterns like "figure shows", "depicts", "illustrates"
    description_patterns = [
      /figure\s*(?:\d+)?\s*(?:shows|depicts|illustrates|represents)\s*([^\n]+)/i,
      /shows\s*([^\n]+)/i,
      /depicts\s*([^\n]+)/i,
      /illustrates\s*([^\n]+)/i,
      /the\s*(?:following|left|right)\s*(?:figure|drawing)\s*(?:shows|depicts|illustrates)\s*([^\n]+)/i,
    ]
    
    description = text.dup
    description_patterns.each do |pattern|
      match = pattern.match(description)
      if match && match[1]
        return match[1].strip
      end
    end
    
    # Fallback: use first sentence
    sentences = text.split(/\.\s*/)
    if sentences.any?
      first_sentence = sentences[0].strip
      first_sentence = first_sentence.gsub(/(figure|Fig\.|Figure)\s*(\d+)?\s*:/i, '')
      first_sentence = first_sentence.gsub(/The\s+(?:following|left|right)\s+/, '')
      return first_sentence.strip[0..500] if first_sentence.length > 500
      return first_sentence
    end
    
    nil
  end
  
  # Extract summary
  def extract_summary(text)
    # Extract key information for summary
    summary_info = []
    
    # Look for key phrases
    key_phrases = [
      /ceramic\s+(?:type|vessel|pot)?/,
      /arrow\s+head/,
      /skeleton/,
      /grave/,
      /burial/,
      /kurgan/,
      /bone\s+tool/,
      /stone\s+tool/,
      /lithic/,
      /weapon/,
      /ornament/,
      /decoration/,
      /rim/,
      /base/,
      /handle/,
      /loop/,
      /spindle/,
      /piercing/
    ]
    
    key_phrases.each do |pattern|
      if pattern.match?(text)
        summary_info << pattern[0]
      end
    end
    
    # Build summary
    if summary_info.any?
      summary = summary_info.join(", ")
      return "Figure shows #{summary}"
    end
    
    # Fallback to description
    description = extract_description(text)
    return description if description
    
    "Figure from archaeological publication"
  end
  
  # Extract key phrases
  def extract_key_phrases(text)
    phrases = []
    
    # Look for common archaeological terms
    terms = [
      "ceramic", "pottery", "vessel", "arrow", "skeleton", 
      "grave", "burial", "kurgan", "lithic", "tool",
      "weapon", "ornament", "decoration", "handle", "rim"
    ]
    
    terms.each do |term|
      if text.include?(term)
        phrases << term
      end
    end
    
    phrases
  end
  
  # Create from raw text
  def self.create_from_ocr_text(figure, ocr_text)
    new_figure_text = new
    new_figure_text.figure = figure
    new_figure_text.ocr_text = ocr_text
    new_figure_text.parse_ocr_text(ocr_text)
    new_figure_text.save!
    
    new_figure_text
  end
end
