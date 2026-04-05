class UpdateSizeFigureController < ApplicationController
  include Wicked::Wizard

  steps :set_data, :set_site, :set_tags, :resize_boxes, :show_contours, :select_pattern_parts, :set_scale, :upload_3d_model, :view_3d_model

  def show
    @figure = Figure.find(params[:size_figure_id])
    @scale = @figure.scale

    render_wizard
  end

  def update
    @figure = Figure.find(params[:size_figure_id])
    @scale = @figure.scale

    case step
    when :set_data
      @figure.update(figure_params)
    when :set_site
      @figure.update(figure_params)
    when :set_tags
      @figure.update(figure_params)
    when :upload_3d_model
      if params[:lithic].present? || params[:figure].present? || params[:ceramic].present?
        @figure.update(figure_params)
      end
    when :set_scale
      if params[:scale].present?
        @scale.update(text: params[:scale][:text])
      else
        values = figure_params
        values[:percentage_scale] = values[:percentage_scale].split(":")[1]

        @figure.update(values)
      end
      AnalyzeScales.new.run([@scale])

      attrs = [:area, :width, :height, :perimeter]

      attrs.each do |attr|
        value = @figure.send(:"#{attr}_with_unit")
        if value[:unit] != "px"
          @figure.send(:"real_world_#{attr}=", value[:value])
        end
      end
      @figure.save!
    when :resize_boxes
      figures = params[:figures]
      figures.permit!
      Figure.update(figures.keys, figures.values).reject { |p| p.errors.empty? }

      figures = Figure.where(id: params[:figures].keys)
      GraveSize.new.run(figures)
      AnalyzeScales.new.run(figures)
    when :select_pattern_parts
      # Handle pattern parts creation/update
      if params[:pattern_parts].present?
        # Destroy existing pattern parts for this figure
        @figure.pattern_parts.destroy_all

        # Create new pattern parts
        params[:pattern_parts].each do |pp_params|
          @figure.pattern_parts.create!(
            x1: pp_params[:x1],
            y1: pp_params[:y1],
            x2: pp_params[:x2],
            y2: pp_params[:y2],
            description: pp_params[:description],
            feature_type: pp_params[:feature_type] || 'texture'
          )
        end
      end
    end

    render_wizard @figure
  end

  # POST /update_size_figure/1/extract_identifier
  def extract_identifier
    @figure = Figure.find(params[:size_figure_id])
    
    # Get the image for this figure
    image_path = get_figure_image_path(@figure)
    
    if image_path && File.exist?(image_path)
      # Get bounding box coordinates
      bounding_box = [@figure.x1, @figure.y1, @figure.x2, @figure.y2]
      
      # Extract identifier using multimodal LLM
      extractor = MultimodalIdentifierExtractor.new
      identifier = extractor.extract_identifier(image_path, @figure.type, bounding_box)
      
      # Update the figure with the extracted identifier
      if identifier.present?
        @figure.update(identifier: identifier)
        flash[:notice] = "Identifier '#{identifier}' extracted successfully."
      else
        flash[:alert] = "Failed to extract identifier."
      end
    else
      flash[:alert] = "Could not find image for this figure."
    end
    
    redirect_back(fallback_location: @figure)
  end

  # GET /update_size_figure/1/show_summary_sources
  def show_summary_sources
    @figure = Figure.find(params[:size_figure_id])
    
    # Extract the summary with sources
    extractor = TextSummaryExtractor.new
    summary = extractor.extract_summary(@figure, @figure.publication_id)
    
    if summary.present?
      # Extract sources from the summary
      sources = extract_sources_from_summary(summary)
      
      # Render the sources
      render json: { sources: sources, summary: summary }
    else
      render json: { error: "No summary available" }, status: :not_found
    end
  end

  private

  def extract_sources_from_summary(summary)
    # Extract sources from the summary
    sources = []
    
    # Look for the sources section
    if summary.include?("Sources:")
      sources_section = summary.split("Sources:").last
      
      # Extract each source line
      sources_section.split("\n").each do |line|
        if line.match(/^\s*\d+\.\s*Page\s+\d+/)
          # Extract page number
          page_number = line.match(/Page\s+(\d+)/)&.captures&.first&.to_i
          sources << { page_number: page_number } if page_number
        end
      end
    end
    
    sources
  end

  def details
    @figure.update(figure_params)

    render_wizard next_step: :scale
  end

  def finish_wizard_path
    cls = @figure.class
    next_lithic = cls.order(:id).where("id > ?", @figure.id).where("probability > 0.6").first
    if !next_lithic.nil?
      size_figure_update_size_figure_path(next_lithic, :set_data)
    else
      lithic_path
    end
  end

  private

  def figure_params
    if params[:ceramic]
      params.require(:ceramic).permit(:identifier, :name, :description, :site_id, :three_d_model, :percentage_scale, :page_size)
    else
      params.require(:lithic).permit(:name, :description, :site_id)
    end
  end

  def get_figure_image_path(figure)
    # Get the image path for the figure
    if figure.page && figure.page.image && figure.page.image.data.attached?
      # Get the path to the image file
      figure.page.image.data.service_url
    else
      # Try to get the image from the figure's bounding box
      nil
    end
  end
end
