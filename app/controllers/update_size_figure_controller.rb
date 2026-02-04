class UpdateSizeFigureController < ApplicationController
  include Wicked::Wizard
  steps :set_data, :set_site, :set_tags, :resize_boxes, :show_contours, :set_scale, :upload_3d_model, :view_3d_model

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
      if params[:lithic].present? || params[:figure].present?
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
    end

    render_wizard @figure
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
      params.require(:ceramic).permit(:name, :description, :site_id, :three_d_model)
    else
      params.require(:lithic).permit(:name, :description, :site_id)
    end
  end
end
