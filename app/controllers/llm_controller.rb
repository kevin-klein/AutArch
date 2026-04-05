class LlmController < ApplicationController
  def summarize
    text = params[:text]
    if text.blank?
      render json: { error: 'No text provided' }, status: 400
      return
    end
    
    summary = LlmService.summarize(text)
    render json: { summary: summary }
  end
  
  def extract_info
    text = params[:text]
    if text.blank?
      render json: { error: 'No text provided' }, status: 400
      return
    end
    
    info = LlmService.extract_info(text)
    render json: { extracted_info: info }
  end
end