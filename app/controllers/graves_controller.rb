class GravesController < ApplicationController
  before_action :set_grave, only: %i[ show edit update destroy ]

  # GET /graves or /graves.json
  def index
    @graves = Grave.includes(:scale, grave_cross_section: { grave: [:scale] }).order(:id).all
  end

  # GET /graves/1 or /graves/1.json
  def show
  end

  def stats

  end

  # GET /graves/new
  def new
    @grave = Grave.new
  end

  # GET /graves/1/edit
  def edit
  end

  # POST /graves or /graves.json
  def create
    @grave = Grave.new(grafe_params)

    respond_to do |format|
      if @grave.save
        format.html { redirect_to grafe_url(@grafe), notice: "Grave was successfully created." }
        format.json { render :show, status: :created, location: @grafe }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @grafe.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /graves/1 or /graves/1.json
  def update
    Grave.transaction do
      result = Figure.update(params[:figures].keys, params[:figures].values).reject { |p| p.errors.empty? }

      # raise
      # angle = grave_params[:arrowAngle]
      # figure_ids = grave_params[:figures].map { _1[:id] }
      # @grave.site_id = grave_params[:site_id]
      # @grave.save!

      # @grave.figures.each do |figure|
      #   unless figure_ids.include?(figure.id)
      #     figure.destroy
      #     next
      #   end

      #   new_figure_data = grave_params[:figures].find { _1[:id] == figure.id }
      #   figure.x1 = new_figure_data[:x1]
      #   figure.x2 = new_figure_data[:x2]
      #   figure.y1 = new_figure_data[:y1]
      #   figure.y2 = new_figure_data[:y2]

      #   if figure.type_name == 'arrow'
      #     arrow = figure.arrow
      #     arrow.angle = angle
      #     arrow.save!
      #   end

      #   figure.save!
      # end

      # grave_params[:figures].select { _1[:id].is_a?(String) }.each do |new_figure|
      #   figure = @grave.figure.page.figures.create!({
      #     tags: []
      #   }.merge(new_figure.except(:id)))

      #   case figure.type_name
      #   when 'arrow'
      #     Arrow.create!(grave: @grave, figure: figure, angle: angle)
      #   when 'skeleton'
      #     Skeleton.create!(grave: @grave, figure: figure)
      #   when 'skull'
      #     Skull.create!(skeleton: @grave.skeletons.first, figure: figure)
      #   when 'good'
      #     Good.create!(grave: @grave, figure: figure)
      #   when 'grave_cross_section'
      #     GraveCrossSection.create!(grave: @grave, figure: figure)
      #   when 'scale'
      #     Scale.create!(grave: @grave, figure: figure)
      #   when 'spine'
      #     Spine.create!(grave: @grave, figure: figure)
      #   when 'cross_section_arrow'
      #     CrossSectionArrow.create!(grave: @grave, figure: figure, length: length)
      #   end
      # end
    end

    redirect_to edit_grave_path(@grave)
  end

  # DELETE /graves/1 or /graves/1.json
  def destroy
    @grave.destroy

    respond_to do |format|
      format.html { redirect_to graves_url, notice: "Grave was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_grave
      @grave = Grave.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def grave_params
      params.require(:grave).permit(:arrowAngle, :site_id, figures: [:id, :type_name, :x1, :x2, :y1, :y2])
    end
end
