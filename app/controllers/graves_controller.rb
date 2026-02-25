class GravesController < AuthorizedController
  before_action :set_grave, only: %i[show edit update destroy related save_related]

  # GET /graves or /graves.json
  def index
    publications = Publication.accessible_by(current_ability)
    graves = Grave.where(publication: publications)
    if params.dig(:search, :publication_id).present?
      filter_id = params.dig(:search, :publication_id)

      if publications.pluck(:id).include?(filter_id)
        graves = Grave
        .joins(page: :publication)
        .where({publication: {id: filter_id}})
      else
        raise CanCan::AccessDenied
      end
    end

    @graves = graves
      .includes(:scale, :site, :publication, :tags, :arrow, page: :image, grave_cross_section: {grave: [:scale]})
      .where("figures.probability > ?", 0.6)

    if params.dig(:search, :site_id).present?
      @graves = @graves.where(site_id: params[:search][:site_id])
    end

    @graves = if params[:sort] == "area:desc"
      @graves.order("real_world_area DESC NULLS LAST")
    elsif params[:sort] == "area:asc"
      @graves.order("real_world_area ASC NULLS LAST")
    elsif params[:sort] == "perimeter:asc"
      @graves.order("real_world_perimeter ASC NULLS LAST")
    elsif params[:sort] == "perimeter:desc"
      @graves.order("real_world_perimeter DESC NULLS LAST")
    elsif params[:sort] == "width:desc"
      @graves.order("real_world_width DESC NULLS LAST")
    elsif params[:sort] == "width:asc"
      @graves.order("real_world_width ASC NULLS LAST")
    elsif params[:sort] == "length:asc"
      @graves.order("real_world_height ASC NULLS LAST")
    elsif params[:sort] == "length:desc"
      @graves.order("real_world_height DESC NULLS LAST")
    elsif params[:sort] == "id:asc"
      @graves.order("id ASC NULLS LAST")
    elsif params[:sort] == "id:desc"
      @graves.order("id DESC NULLS LAST")
    elsif params[:sort] == "depth:desc"
      @graves.order("real_world_depth DESC NULLS LAST")
    elsif params[:sort] == "depth:asc"
      @graves.order("real_world_depth DESC NULLS LAST")
    elsif params[:sort] == "site:asc"
      @graves.joins(:site).reorder("sites.name ASC NULLS LAST")
    elsif params[:sort] == "site:desc"
      @graves.joins(:site).reorder("sites.name DESC NULLS LAST")
    elsif params[:sort] == "publication:asc"
      @graves.joins(:publication).reorder("publications.author ASC NULLS LAST")
    elsif params[:sort] == "publication:desc"
      @graves.joins(:publication).reorder("publications.author DESC NULLS LAST")
    else
      @graves.joins(:publication).reorder("figures.created_at")
    end

    @graves_pagy, @graves = pagy(@graves.all)
  end

  def orientations
    tag_id = Tag.find_by(name: params[:name])
    @skeleton_angles = Site.includes(
      graves: [:spines, :arrow]
    ).all.to_a.map do |site|
      # 3 = corded ware
      # 2 = bell beaker

      spines = site.graves.joins(:tags).where(tags: {id: tag_id}).flat_map do |grave|
        grave.spines
      end

      angles = Stats.all_spine_angles(spines).to_a
      angles
    end.filter do |grave_data|
      grave_data.sum > 0
    end.flatten
  end

  # GET /graves/1 or /graves/1.json
  def show
  end

  def related
    @page = @grave.page
    @grave_good_ids = @grave.goods.pluck(:id)
    @related_artefacts = Figure.where(type: ["Ceramic", "StoneTool", "Artefact", "ShaftAxe"]).where(parent_id: @grave_good_ids)
    @relations = @grave_good_ids.map do |grave_good_id|
      [grave_good_id, @related_artefacts.filter { _1.parent_id == grave_good_id }.pluck(:id)]
    end.to_h
  end

  def save_related
    Figure.transaction do
      relations = params[:relations].permit!.to_h
      relations.each do |good_id, full_drawing_ids|
        next if full_drawing_ids.nil?
        Figure.where(parent_id: good_id).update_all(parent_id: nil)
        Figure.where(id: full_drawing_ids).update_all(parent_id: good_id)
      end
    end
  end

  def root
    @no_box = true

    # @skeleton_angles = Site.includes(
    #   graves: [:spines, :arrow]
    # ).all.to_a.map do |site|
    #   spines = site.graves.flat_map do |grave|
    #     grave.spines
    #   end

    #   angles = Stats.spine_angles(spines)

    #   {
    #     site: site,
    #     angles:
    #   }
    # end.filter do |grave_data|
    #   grave_data[:angles].values.sum > 0
    # end

    @skeleton_angles = []
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
    @grave.delete

    respond_to do |format|
      format.html { redirect_to grave_update_grave_path(Grave.order(:id).where("id > ?", @grave.id).first || @grave.last, :set_grave_data), notice: "Grave was successfully removed." }
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
