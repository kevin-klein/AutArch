class UpdateGraveController < ApplicationController
  include Wicked::Wizard
  steps :set_grave_data, :set_site, :set_tags, :resize_boxes, :show_contours, :set_scale, :set_north_arrow, :set_skeleton_data

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
      Figure.update(params[:figures].keys, params[:figures].values).reject { |p| p.errors.empty? }

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

  def finish_wizard_path
    next_grave = Grave.order(:id).where("id > ?", @grave.id).first
    if !next_grave.nil?
      grave_update_grave_path(next_grave, :set_grave_data)
    else
      graves_path
    end
  end

  def grave_params
    if params[:grave]
      params.require(:grave).permit(
        :percentage_scale,
        :page_size,
        :identifier,
        :site_id,
        tag_ids: [],
        skeleton_figures_attributes: %i[id deposition_type]
      )
    else
      {}
    end
  end
end
