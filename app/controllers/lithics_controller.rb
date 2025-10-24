class LithicsController < ApplicationController
  before_action :set_lithic, only: %i[show edit update destroy related sam_contour]

  def index
    lithics = StoneTool.where(publication: Publication.accessible_by(current_ability))
    if params.dig(:search, :publication_id).present?
      lithics = StoneTool
        .joins(page: :publication)
        .order(:id)
        .where({publication: {id: params.dig(:search, :publication_id)}})
    end

    @lithics = lithics
      .includes(:tags, :scale, :publication, page: :image)
      .where("figures.probability > ?", 0.6)

    if params.dig(:search, :site_id).present?
      @lithics = @lithics.where(site_id: params[:search][:site_id])
    end

    @lithics_pagy, @lithics = pagy(@lithics.all)
  end

  def destroy
    @lithic.delete

    respond_to do |format|
      format.html { redirect_to lithic_update_lithic_path(StoneTool.order(:id).where("id > ?", @lithic.id).first || @lithic.last, :set_lithic_data), notice: "Lithic was successfully removed." }
      format.json { head :no_content }
    end
  end

  def sam_contour
    AnalyzeContourSam.new.run(@lithic, JSON.parse(params[:points]))
    GraveSize.new.existing_contour_stats(@lithic)

    render json: {
      contour: @lithic.contour
    }
  end

  private

  def set_lithic
    @lithic = StoneTool.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def lithic_params
    params.require(:lithic).permit(:arrowAngle, :site_id, figures: %i[id type_name x1 x2 y1 y2])
  end
end
