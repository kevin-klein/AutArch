class UpdateGraveController < AuthorizedController
  include Wicked::Wizard

  steps :set_grave_data, :set_site, :set_tags, :resize_boxes, :show_contours, :set_scale, :set_north_arrow, :set_skeleton_data

  def skeleton_keypoints
    # skeleton = SkeletonFigure.find(params[:skeleton_id])
    # keypoints = AnalyzeSkeleton.new.run(skeleton)
    # # raise
    # skeleton.key_points.destroy_all
    # keypoints[0].each do |name, data|
    #   next if data[:x].nil?
    #   skeleton.key_points.create!(
    #     label: name,
    #     x: data[:x],
    #     y: data[:y]
    #   )
    # end

    # redirect_to grave_update_grave_path(params[:grave_id], :set_skeleton_data)
  end

  def show
    @grave = Grave.find(params[:grave_id])
    @scale = @grave.scale
    @skeleton_figures = @grave.skeleton_figures

    render_wizard
  end

  def update
    @grave = Grave.find(params[:grave_id])
    @scale = @grave.scale

    case step
    when :set_grave_data, :set_skeleton_data
      @grave.update(grave_params)
    when :set_site
      @grave.update(grave_params)
    when :set_tags
      @grave.update(grave_params)
    when :set_scale
      if params[:scale].present?
        @scale.update(text: params[:scale][:text])
      else
        values = grave_params
        values[:percentage_scale] = values[:percentage_scale].split(":")[1]

        @grave.update(values)
      end

      attrs = [:area, :width, :height, :perimeter]

      attrs.each do |attr|
        value = @grave.send(:"#{attr}_with_unit")
        if value[:unit] != "px"
          @grave.send(:"real_world_#{attr}=", value[:value])
        end
      end

      @grave.save!
    when :resize_boxes
      Figure.update(params[:figures].permit!.keys, params[:figures].permit!.values).reject { |p| p.errors.empty? }

      figures = Figure.where(id: params[:figures].keys)
      GraveSize.new.run(figures)
      AnalyzeScales.new.run(figures)
      GraveAngles.new.run(figures.select { _1.is_a?(Arrow) })
      SkeletonPosition.new.run(figures.select { _1.is_a?(SkeletonFigure) })
    when :set_north_arrow
      arrow = @grave.arrow
      arrow.angle = params[:figures][arrow.id.to_s][:angle]
      arrow.save!

      skip_step if @grave.skeleton_figures.empty?
    end

    render_wizard @grave
  end

  # POST /update_grave/1/extract_identifier
  def extract_identifier
    @grave = Grave.find(params[:grave_id])

    # Get the image for this grave
    image_path = get_grave_image_path(@grave)

    if image_path && File.exist?(image_path)
      # Get bounding box coordinates
      bounding_box = [@grave.x1, @grave.y1, @grave.x2, @grave.y2]

      # Extract identifier using multimodal LLM
      extractor = MultimodalIdentifierExtractor.new
      identifier = extractor.extract_identifier(image_path, "Grave", bounding_box)

      # Update the grave with the extracted identifier
      if identifier.present?
        @grave.update(identifier: identifier)
        flash[:notice] = "Identifier '#{identifier}' extracted successfully."
      else
        flash[:alert] = "Failed to extract identifier."
      end
    else
      flash[:alert] = "Could not find image for this grave."
    end

    redirect_back(fallback_location: @grave)
  end

  # GET /update_grave/1/show_summary_sources
  def show_summary_sources
    @grave = Grave.find(params[:grave_id])

    # Extract the summary with sources
    extractor = TextSummaryExtractor.new
    summary = extractor.extract_summary(@grave, @grave.publication_id)

    if summary.present?
      # Extract sources from the summary
      sources = extract_sources_from_summary(summary)

      # Render the sources
      render json: {sources: sources, summary: summary}
    else
      render json: {error: "No summary available"}, status: :not_found
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
        if /^\s*\d+\.\s*Page\s+\d+/.match?(line)
          # Extract page number
          page_number = line.match(/Page\s+(\d+)/)&.captures&.first&.to_i
          sources << {page_number: page_number} if page_number
        end
      end
    end

    sources
  end

  def finish_wizard_path
    next_grave = Grave.order(:id).where("id > ?", @grave.id).where("probability > 0.6").first
    if !next_grave.nil?
      grave_update_grave_path(next_grave, :set_grave_data)
    else
      graves_path
    end
  end

  def grave_params
    if params[:grave]
      params.require(:grave).permit!
    else
      {}
    end
  end

  private

  def get_grave_image_path(grave)
    grave.page.image.file_path
  end
end
