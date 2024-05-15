class UpdateGraveController < ApplicationController
  include Wicked::Wizard
  steps :set_grave_data, :set_site, :resize_boxes, :show_contours, :set_scale, :set_north_arrow, :set_skeleton_data

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
    when :set_scale
      if params[:scale].present?
        @scale.update(text: params[:scale][:text])
      else
        @grave.update(grave_params)
      end
    when :resize_boxes
      Figure.update(params[:figures].keys, params[:figures].values).reject { |p| p.errors.empty? }

      figures = Figure.where(id: params[:figures].keys)
      GraveSize.new.run(figures)
      AnalyzeScales.new.run(figures)
      # GraveAngles.new.run(figures.select { _1.is_a?(Arrow) })
      # SkeletonPosition.new.run(figures.select { _1.is_a?(SkeletonFigure) })
    when :set_north_arrow
      arrow = @grave.arrow
      arrow.angle = params[:figures][arrow.id.to_s][:angle]
      arrow.save!

      skip_step if @grave.skeleton_figures.empty?
    end

    render_wizard @grave
  end

  def grave_params
    params.require(:grave).permit(
      :percentage_scale,
      :page_size,
      :identifier,
      :site_id,
      skeleton_figures_attributes: %i[id deposition_type]
    )
  end
end
