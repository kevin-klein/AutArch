class AnalysisWizardsController < ApplicationController
  before_action :set_wizard, only: [:show, :update, :save_ceramic, :step_2, :step_3, :similar_ceramics]
  before_action :set_page, only: [:create, :step_1]
  # do not add authentication here

  def create
    @wizard = AnalysisWizard.new(
      step: 0,
      page: @page
    )

    if @wizard.save
      render json: {id: @wizard.id}, status: :created
    else
      render json: {errors: @wizard.errors}, status: :unprocessable_entity
    end
  end

  def show
    render json: @wizard
  end

  def update
    if @wizard.update(wizard_params)
      render json: @wizard
    else
      render json: {errors: @wizard.errors}, status: :unprocessable_entity
    end
  end

  def advance_step
    set_wizard
    @wizard.advance_step
    render json: @wizard
  end

  def step_1
    set_page
    result = detect_and_create_figures_from_boxes
    @wizard.update(contours: result[:figure_ids])
    @wizard.update(state: {step_1_results: result[:object_detection]})
    @wizard.advance_step

    # Return first figure ID for similarity step
    first_figure = result[:figures].first
    render json: {
      figures: result[:figures],
      wizard: @wizard,
      step: @wizard.step,
      first_figure_id: first_figure&.id
    }
  rescue => e
    render json: {error: e.message}, status: :unprocessable_entity
  end

  def step_2
    set_wizard
    @wizard.advance_step
    render json: {wizard: @wizard, step: @wizard.step}
  end

  def step_3
    set_wizard
    @wizard.advance_step
    render json: {wizard: @wizard, step: @wizard.step}
  end

  def similar_ceramics
    set_wizard
    @figure = Ceramic.find(params[:figure_id])

    if @figure.publication_id.nil?
      render json: {error: "Publication not found for this ceramic"}, status: :unprocessable_entity
      return
    end

    # Get all ceramics from the same publication
    @publication_ceramics = Ceramic.where(publication_id: @figure.publication_id)
      .where.not(id: @figure.id)
      .includes(:page)
      .select(:id, :name, :description, :features, :page_id)

    # Calculate similarity with all ceramics
    @similarities = @publication_ceramics.map do |ceramic|
      next if ceramic.features.blank?

      similarity = CosineSimilarity.similarity(ceramic.features, @figure.features || [])
      {
        ceramic_id: ceramic.id,
        name: ceramic.name,
        description: ceramic.description,
        similarity: similarity,
        features: ceramic.features,
        image: extract_figure_image(ceramic)
      }
    end.compact

    # Sort by similarity (descending) and take top 5
    @similarities = @similarities.sort_by { |s| -s[:similarity] }.take(5)

    render json: {
      figure: {
        id: @figure.id,
        name: @figure.name,
        features: @figure.features,
        image: extract_figure_image(@figure)
      },
      similar_ceramics: @similarities,
      total_compared: @similarities.length
    }
  rescue => e
    render json: {error: e.message}, status: :unprocessable_entity
  end

  def extract_figure_image(figure)
    return nil unless figure&.page&.image&.data

    begin
      image_data = MinOpenCV.extractFigure(figure, figure.page.image.data)
      image_data = MinOpenCV.imencode(image_data)
      "data:image/jpeg;base64,#{Base64.encode64(image_data)}"
    rescue => e
      Rails.logger.error("Failed to extract figure image: #{e.message}")
      nil
    end
  end

  def save_ceramic
    set_wizard
    figure = Ceramic.find(params[:figure_id])

    # Extract BOVW features from image using torch_service
    features = extract_bovw_features(image: params[:image], points: params[:points])

    @wizard.add_ceramic(figure_id: figure.id, bovw_features: features)

    # Store result for similarity calculation
    @wizard.store_result(figure)

    render json: {wizard: @wizard, ceramic_id: figure.id, similarity: calculate_similarity(figure, features)}
  end

  def extract_bovw_features(image:, points:)
    return nil unless image

    # Upload image to torch_service for feature extraction
    begin
      # Create a file-like object for the image
      io = StringIO.new(image)
      file = HTTP::FormData::File.new io, filename: "ceramic.jpg", headers: {"Content-Type" => "image/jpeg"}

      response = HTTP.post("#{ENV["ML_SERVICE_URL"]}/features", form: {
        image: file
      })

      if response.status == 200
        result = response.parse
        features = result["features"]
        Rails.logger.info("BOVW features extracted: #{features.inspect}")
        return features
      else
        Rails.logger.error("Torch service returned status: #{response.status}")
      end
    rescue => e
      Rails.logger.error("BOVW feature extraction failed: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
    end

    nil
  end

  def calculate_similarity(figure, bovw_features)
    # Calculate cosine similarity
    if figure.features && bovw_features
      CosineSimilarity.similarity(figure.features, bovw_features)
    else
      1.0
    end
  end

  private

  def set_wizard
    @wizard = AnalysisWizard.find(params[:id])
  end

  def set_page
    @page = Page.find(params[:page_id])
  rescue
    @page = nil
  end

  def wizard_params
    params.permit(:step, :page_id, :contours, :state)
  end
end
