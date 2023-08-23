class UpdateGraveController < ApplicationController
  include Wicked::Wizard
  steps :resize_boxes, :show_contours, :set_scale, :set_north_arrow, :set_skeleton_data

  def show
    @grave = Grave.find(params[:grave_id])
    @scale = @grave.scale
    @skeleton_figures = @grave.skeleton_figures

    case step
    when :set_north_arrow
    end
    render_wizard
  end

  def update
    @grave = Grave.find(params[:grave_id])
    @scale = @grave.scale

    case step
    when :set_skeleton_data
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
      GraveAngles.new.run(figures.select { _1.is_a?(Arrow) })
    when :set_north_arrow
      arrow = @grave.arrow
      arrow.angle = params[:figures][arrow.id.to_s][:angle]
      arrow.save!

      if @grave.skeleton_figures.size == 0
        skip_step
      end
    end

    render_wizard @grave
  end

  def grave_params
    params.require(:grave).permit(
      :percentage_scale,
      :page_size,
      skeleton_figures_attributes: %i[id deposition_type]
    )
  end
end
