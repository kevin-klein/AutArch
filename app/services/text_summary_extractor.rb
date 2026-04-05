class TextSummaryExtractor
  def initialize
    @api_key = ENV['QWEN_API_KEY']
    @base_url = ENV['QWEN_API_URL'] || 'https://dashscope.aliyuncs.com/api/v1/services/qwen-vl-plus'
  end

  def extract_summary(figure, publication_id)
    # Get all pages of the publication
    pages = Page.where(publication_id: publication_id).order(:number)
    
    # Create a summary by analyzing all pages
    summary_parts = []
    sources = []
    
    # Get the figure's identifier (if available)
    figure_identifier = figure.identifier || "Figure #{figure.id}"
    
    # Analyze all pages for text related to this figure
    pages.each do |page|
      if page.image && page.image.data.attached?
        image_path = page.image.data.service_url
        if image_path && File.exist?(image_path)
          # Extract summary for this page, looking for text related to the figure
          page_summary = extract_page_summary(image_path, figure.type, page.number, publication_id, figure_identifier)
          if page_summary.present?
            summary_parts << page_summary
            
            # Extract line numbers from the summary if available
            line_numbers = extract_line_numbers(page_summary)
            
            sources << { 
              page_number: page.number, 
              summary: page_summary, 
              line_numbers: line_numbers 
            }
          end
        end
      end
    end
    
    # Combine all summaries
    if summary_parts.any?
      # Create a final summary by combining all parts
      final_summary = combine_summaries(summary_parts, figure.type, figure_identifier)
      
      # If this is a grave, try to extract goods information
      if figure.type == 'Grave' && final_summary.present?
        # Extract goods information
        goods_info = extract_goods_information(figure, publication_id, final_summary)
        
        # Add goods information to the summary
        if goods_info.present?
          final_summary += "\n\nGoods associated with this grave: #{goods_info}"
        end
      end
      
      # Self-validation: ask Qwen to validate its own output
      validation_result = validate_summary_with_qwen(final_summary, figure.type)
      
      # Return the summary only if Qwen validates it
      if validation_result && validation_result[:is_valid]
        # Add sources information to the summary
        sources_info = "\n\nSources:\n"
        sources.each_with_index do |source, index|
          sources_info += "#{index + 1}. Page #{source[:page_number]}"
          if source[:line_numbers].any?
            sources_info += " (Lines: #{source[:line_numbers].join(', ')})"
          end
          sources_info += "\n"
        end
        final_summary += sources_info
        final_summary
      else
        Rails.logger.warn("Qwen self-validation failed for figure #{figure.id} (#{figure.type}): #{validation_result[:explanation]}")
        nil
      end
    else
      nil
    end
  end

  def extract_summary_with_retry(figure, publication_id, max_attempts = 3)
    attempts = 0
    
    while attempts < max_attempts
      attempts += 1
      
      # Extract summary
      summary = extract_summary(figure, publication_id)
      
      # If we got a summary, return it
      return summary if summary.present?
      
      # If validation failed, log the attempt
      Rails.logger.info("Attempt #{attempts} failed for figure #{figure.id} (#{figure.type})")
    end
    
    # If all attempts failed, return nil
    nil
  end

  private

  def validate_summary_with_qwen(summary, figure_type)
    # Create a validation prompt
    prompt = "Please validate the following summary for a #{figure_type} figure:\n\n#{summary}\n\nIs this a reasonable, concise summary (2-3 sentences) that captures the key information about the figure? Answer with 'YES' if it's valid, 'NO' if it's not valid, and provide a brief explanation. Also indicate if the summary contains relevant information about the figure type."
    
    # Make API request to Qwen 3.5 VL
    response = make_api_request(nil, prompt)
    
    # Extract validation result
    extract_validation_result(response)
  end

  def extract_validation_result(response)
    if response['output'] && response['output']['choices'] && response['output']['choices'].any?
      text = response['output']['choices'][0]['message']['content']
      
      # Parse the validation result
      is_valid = text.downcase.include?('yes') && !text.downcase.include?('no')
      explanation = text.gsub(/^(YES|NO)\s*/i, '').strip
      
      { is_valid: is_valid, explanation: explanation }
    else
      { is_valid: false, explanation: 'No validation response received' }
    end
  end

  private

  def extract_goods_information(figure, publication_id, summary)
    # Get all pages of the publication
    pages = Page.where(publication_id: publication_id).order(:number)
    
    # Create a list of goods by analyzing all pages
    goods_list = []
    
    # Get the figure's identifier (if available)
    figure_identifier = figure.identifier || "Figure #{figure.id}"
    
    # Analyze all pages for goods information related to this grave
    pages.each do |page|
      if page.image && page.image.data.attached?
        image_path = page.image.data.service_url
        if image_path && File.exist?(image_path)
          # Extract goods information for this page
          page_goods = extract_page_goods(image_path, page.number, publication_id, figure_identifier)
          goods_list.concat(page_goods) if page_goods.any?
        end
      end
    end
    
    # Return goods information as a string
    if goods_list.any?
      goods_list.join(', ')
    else
      nil
    end
  end

  def extract_page_goods(image_path, page_number, publication_id, figure_identifier)
    # Convert image to base64 for API request
    image_data = File.read(image_path)
    image_base64 = Base64.encode64(image_data)
    
    # Prepare the prompt to extract goods information
    prompt = "Identify any goods associated with the grave figure identified as '#{figure_identifier}' from publication #{publication_id} that are mentioned on this page. Look for descriptions of goods, their identifiers, and any detailed drawings of these goods. Return a list of goods with their identifiers and descriptions (if available)."
    
    # Make API request to Qwen 3.5 VL
    response = make_api_request(image_base64, prompt)
    
    # Extract and return the goods information
    extract_goods_from_response(response)
  end

  def extract_goods_from_response(response)
    # Extract the goods information from the response
    if response['output'] && response['output']['choices'] && response['output']['choices'].any?
      text = response['output']['choices'][0]['message']['content']
      # Clean up the response
      text.strip.gsub(/
+/, ' ').gsub(/[^a-zA-Z0-9\s\.,;:!?\-\(\)\[\]\"\'\n]/, '').strip
    else
      nil
    end
  end

  private

  def extract_page_summary(image_path, figure_type, page_number, publication_id, figure_identifier)
    # Convert image to base64 for API request
    image_data = File.read(image_path)
    image_base64 = Base64.encode64(image_data)
    
    # Prepare the prompt based on figure type
    prompt = case figure_type
             when 'Grave'
               "Summarize any text on this page that might be related to the grave figure identified as '#{figure_identifier}' from publication #{publication_id}. Look for descriptions, measurements, location, artifacts found, or any other relevant information about this grave. Also identify any goods associated with this grave and their detailed drawings (if mentioned in the text). Return a concise summary of 2-3 sentences. Include the line numbers of the text that you are summarizing."
             when 'StoneTool'
               "Summarize any text on this page that might be related to the stone tool figure identified as '#{figure_identifier}' from publication #{publication_id}. Look for descriptions, measurements, material, dimensions, or any other relevant information about this tool. Return a concise summary of 2-3 sentences. Include the line numbers of the text that you are summarizing."
             when 'Ceramic'
               "Summarize any text on this page that might be related to the ceramic figure identified as '#{figure_identifier}' from publication #{publication_id}. Look for descriptions, measurements, decoration, dimensions, or any other relevant information about this ceramic. Return a concise summary of 2-3 sentences. Include the line numbers of the text that you are summarizing."
             else
               "Summarize any text on this page that might be related to the archaeological figure identified as '#{figure_identifier}' from publication #{publication_id}. Look for descriptions, measurements, or any other relevant information about this figure. Return a concise summary of 2-3 sentences. Include the line numbers of the text that you are summarizing."
             end
    
    # Make API request to Qwen 3.5 VL
    response = make_api_request(image_base64, prompt)
    
    # Extract and return the summary
    extract_summary_from_response(response)
  end

  def combine_summaries(summary_parts, figure_type, figure_identifier)
    # Create a final summary by combining all parts
    if summary_parts.length == 1
      summary_parts.first
    else
      # Create a prompt to combine the summaries
      prompt = "Combine these #{summary_parts.length} summaries about the #{figure_type} figure identified as '#{figure_identifier}' into a single concise summary of 2-3 sentences. Focus on the most important details about the figure's characteristics, location, and any other relevant information. Also include information about any goods associated with this figure and their detailed drawings (if mentioned in the text). Here are the summaries: #{summary_parts.join(' \n\n ')}"
      
      # Make API request to Qwen 3.5 VL to combine summaries
      response = make_api_request(nil, prompt)
      
      # Extract and return the combined summary
      extract_summary_from_response(response)
    end
  end

  private

  def make_api_request(image_base64, prompt)
    # This is a simplified example - you'll need to adapt to Qwen's actual API
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
      temperature: 0.3,
      max_tokens: 200
    }.to_json
    
    response = http.request(request)
    JSON.parse(response.body)
  rescue => e
    Rails.logger.error("Qwen API error: #{e.message}")
    { 'error' => e.message }
  end

  def extract_summary_from_response(response)
    # Extract the summary from the response
    if response['output'] && response['output']['choices'] && response['output']['choices'].any?
      text = response['output']['choices'][0]['message']['content']
      # Clean up the response
      text.strip.gsub(/+/, ' ').strip
    else
      nil
    end
  end
  
  private
  
  def extract_line_numbers(summary)
    # Extract line numbers from the summary if available
    # Look for patterns like "Line 12", "Lines 15-20", "line 3, 5, 7", etc.
    line_numbers = []
    
    # Look for "Line" or "Lines" followed by numbers
    if summary.match(/(Line|Lines)\s+(\d+(-\d+)?(,\s*\d+(-\d+)?)*)(\s*and\s*\d+(-\d+)?)*|line\s+(\d+(-\d+)?(,\s*\d+(-\d+)?)*)(\s*and\s*\d+(-\d+)?)*/i)
      # Extract the line numbers
      line_numbers_str = summary.match(/(Line|Lines)\s+(\d+(-\d+)?(,\s*\d+(-\d+)?)*)(\s*and\s*\d+(-\d+)?)*|line\s+(\d+(-\d+)?(,\s*\d+(-\d+)?)*)(\s*and\s*\d+(-\d+)?)*/i)[0]
      
      # Extract the actual numbers
      numbers = line_numbers_str.gsub(/[^\d\-\,\s]/, '').strip.split(/\s*,\s*|\s+and\s+/)
      
      numbers.each do |num_str|
        if num_str.include?('-')
          # Handle ranges like "12-20"
          start, finish = num_str.split('-').map(&:to_i)
          (start..finish).each { |n| line_numbers << n }
        else
          # Handle single numbers
          line_numbers << num_str.to_i
        end
      end
    end
    
    line_numbers.uniq.sort
  end