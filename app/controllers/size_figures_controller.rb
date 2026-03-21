class SizeFiguresController < ApplicationController
  before_action :set_figure_class
  before_action :set_figure, only: %i[destroy sam_contour]
  skip_forgery_protection only: [:boxes]

  def index
    @figures = @figure_cls.where(publication: Publication.accessible_by(current_ability))
    if params.dig(:search, :publication_id).present?
      @figures = @figure_cls
        .joins(page: :publication)
        .order(:id)
        .where({publication: {id: params.dig(:search, :publication_id)}})
    end

    @figures = @figures
      .includes(:tags, :scale, :publication, page: :image)
      .where("figures.probability > ?", 0.6)

    if params.dig(:search, :site_id).present?
      @figures = @figures.where(site_id: params[:search][:site_id])
    end

    @figures_pagy, @figures = pagy(@figures.all)
  end

  def destroy
    @figure.delete

    respond_to do |format|
      format.html { redirect_to size_figure_update_size_figure_path(@figure.class.order(:id).where("id > ?", @figure.id).first || @figure.class.last, :set_data), notice: "Figure was successfully removed." }
      format.json { head :no_content }
    end
  end

  def sam_contour
    AnalyzeContourSam.new.run(@figure, JSON.parse(params[:points]))
    GraveSize.new.existing_contour_stats(@figure)

    render json: {
      contour: @figure.contour
    }
  end

  def update_contour
    uploaded_file = params[:image]

    vips_image = Vips::Image.new_from_buffer(uploaded_file.read, "")
    image_data = vips_image.write_to_buffer(".jpg")
    points = JSON.parse(params[:points])

    render json: {
      contour: AnalyzeContourSam.new.segment(image_data, points)["contour"]
    }
  end

  def boxes
    uploaded_file = params[:image]

    if uploaded_file.present?
      begin
        vips_image = Vips::Image.new_from_buffer(uploaded_file.read, "")

        image_data = vips_image.write_to_buffer(".jpg")

        predictions = AnalyzePublication.new.predict_boxes(image_data)

        predictions = predictions
          .filter do |pred|
            pred["label"] == params[:object_type]
          end
          .map do |prediction|
            x1, y1, x2, y2 = prediction["box"]
            center = [(x1 + x2) / 2, (y1 + y2) / 2].map(&:to_i)
            prediction.merge({
              id: SecureRandom.hex,
              contour: AnalyzeContourSam.new.segment(image_data, [center])["contour"][0]
            })
          end

        # Simple JSON response – adjust as needed for your front‑end
        render json: {status: "success", boxes: predictions}
      rescue => e
        # Handle any conversion errors
        render json: {error: e.message}, status: :unprocessable_entity
      end
    else
      # No file was provided
      render json: {error: "No image uploaded"}, status: :bad_request
    end
  end

  def new_box
    uploaded_file = params[:image]

    vips_image = Vips::Image.new_from_buffer(uploaded_file.read, "")
    image_data = vips_image.write_to_buffer(".jpg")
    points = JSON.parse(params[:points])

    render json: {
      id: SecureRandom.hex,
      contour: AnalyzeContourSam.new.segment(image_data, points)["contour"][0]
    }
  end

  private

  def set_figure_class
    @figure_cls = {
      "lithics" => StoneTool,
      "ceramics" => Ceramic
    }[params[:figure_type]]
    @figure_cls ||= Figure
  end

  def set_figure
    @figure = @figure_cls.find(params[:size_figure_id] || params[:id])
  end
end
