class UpdateLithicController < ApplicationController
  include Wicked::Wizard
  steps :set_lithic_data, :set_site, :set_tags, :resize_boxes, :show_contours, :set_scale

  def show
    @lithic = StoneTool.find(params[:lithic_id])
    @scale = @lithic.scale

    render_wizard
  end

  def update
    @lithic = StoneTool.find(params[:lithic_id])
    @scale = @lithic.scale

    case step
    when :set_lithic_data
      @lithic.update(lithic_params)
    when :set_site
      @lithic.update(lithic_params)
    when :set_tags
      @lithic.update(lithic_params)
    when :set_scale
      if params[:scale].present?
        @scale.update(text: params[:scale][:text])
      else
        values = lithic_params_params
        values[:percentage_scale] = values[:percentage_scale].split(":")[1]

        @lithic.update(values)
      end
      AnalyzeScales.new.run([@scale])

      attrs = [:area, :width, :height, :perimeter]

      attrs.each do |attr|
        value = @lithic.send(:"#{attr}_with_unit")
        if value[:unit] != "px"
          @lithic.send(:"real_world_#{attr}=", value[:value])
        end
      end
      @lithic.save!
    when :resize_boxes
      Figure.update(params[:figures].keys, params[:figures].values).reject { |p| p.errors.empty? }

      figures = Figure.where(id: params[:figures].keys)
      GraveSize.new.run(figures)
      AnalyzeScales.new.run(figures)
    end

    render_wizard @lithic
  end

  def details
    @lithic.update(lithic_params)

    render_wizard next_step: :scale
  end

  def finish_wizard_path
    next_lithic = StoneTool.order(:id).where("id > ?", @lithic.id).where("probability > 0.6").first
    if !next_lithic.nil?
      lithic_update_lithic_path(next_lithic, :set_lithic_data)
    else
      lithic_path
    end
  end

  private

  def lithic_params
    params.require(:lithic).permit(:name, :description)
  end
end
