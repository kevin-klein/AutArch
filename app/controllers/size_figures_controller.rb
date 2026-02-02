class SizeFiguresController < ApplicationController
  before_action :set_figure_class
  before_action :set_figure, only: %i[destroy sam_contour]

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

  private

  def set_figure_class
    @figure_cls = {
      'lithics' => StoneTool,
      'ceramics' => Ceramic
    }[params[:figure_type]]
    @figure_cls ||= Figure
  end

  def set_figure
    @figure = @figure_cls.find(params[:size_figure_id] || params[:id])
  end
end
