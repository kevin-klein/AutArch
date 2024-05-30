class GravesController < AuthorizedController
  before_action :set_grave, only: %i[show edit update destroy]

  # GET /graves or /graves.json
  def index
    graves = Grave.where(publication: Publication.accessible_by(current_ability))
    if params.dig(:search, :publication_id).present?
      graves = Grave
        .joins(page: :publication)
        .where({publication: {id: params.dig(:search, :publication_id)}})
    end

    @graves = graves
      .includes(:scale, :site, :publication, :arrow, page: :image, grave_cross_section: {grave: [:scale]})
      .where("probability > ?", 0.6)

    if params[:sort] == "area:desc"
      @graves = @graves.order("real_world_area DESC NULLS LAST")
    elsif params[:sort] == "area:asc"
      @graves = @graves.order("real_world_area ASC NULLS LAST")
    elsif params[:sort] == "perimeter:asc"
      @graves = @graves.order("real_world_perimeter ASC NULLS LAST")
    elsif params[:sort] == "perimeter:desc"
      @graves = @graves.order("real_world_perimeter DESC NULLS LAST")
    elsif params[:sort] == "width:desc"
      @graves = @graves.order("real_world_width DESC NULLS LAST")
    elsif params[:sort] == "width:asc"
      @graves = @graves.order("real_world_width ASC NULLS LAST")
    elsif params[:sort] == "length:asc"
      @graves = @graves.order("real_world_height ASC NULLS LAST")
    elsif params[:sort] == "length:desc"
      @graves = @graves.order("real_world_height DESC NULLS LAST")
    end

    @graves_pagy, @graves = pagy(@graves.all)
  end

  # GET /graves/1 or /graves/1.json
  def show
  end

  def root
    @no_box = true
  end

  def stats
  end

  # GET /graves/new
  def new
    @grave = Grave.new
  end

  # GET /graves/1/edit
  def edit
    @no_box = true

    ap step
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
      Figure.update(params[:figures].keys, params[:figures].values).reject { |p| p.errors.empty? }

      figures = Figure.where(id: params[:figures].keys)
      GraveSize.new.run(figures)
      AnalyzeScales.new.run(figures)
    end

    redirect_to edit_grave_path(@grave)
  end

  # DELETE /graves/1 or /graves/1.json
  def destroy
    @grave.destroy!

    respond_to do |format|
      format.html { redirect_to edit_grave_path(Grave.order(:id).where("id > ?", @grave.id).first || @grave.last), notice: "Grave was successfully destroyed." }
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
    params.require(:grave).permit(:arrowAngle, :site_id, figures: %i[id type_name x1 x2 y1 y2])
  end
end
