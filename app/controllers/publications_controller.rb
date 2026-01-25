class PublicationsController < AuthorizedController
  before_action :set_publication, only: %i[analysis export_lithics export radar update_tags assign_tags update_site assign_site progress summary show edit update destroy stats]

  # GET /publications or /publications.json
  def index
    @publications = Publication.accessible_by(current_ability).select(:id, :public, :user_id, :title, :author, :year)

    @publications = if params[:sort] == "title:asc"
      @publications.order("title ASC NULLS LAST")
    elsif params[:sort] == "title:desc"
      @publications.order("title DESC NULLS LAST")
    elsif params[:sort] == "author:desc"
      @publications.order("author DESC NULLS LAST")
    elsif params[:sort] == "author:asc"
      @publications.order("author ASC NULLS LAST")
    elsif params[:sort] == "year:asc"
      @publications.order("year ASC NULLS LAST")
    elsif params[:sort] == "year:desc"
      @publications.order("year DESC NULLS LAST")
    else
      @publications.order(:created_at)
    end
  end

  # GET /publications/1 or /publications/1.json
  def show
    @publication
  end

  def assign_site
  end

  def assign_tags
  end

  def update_site
    @publication.figures.update_all(site_id: params[:site][:site_id])

    redirect_to publications_path
  end

  def update_tags
    tags = params[:tags].permit!.to_h[:tags].filter { !_1.blank? }.map do |tag_id|
      Tag.find(tag_id)
    end

    @publication.figures.where(type: "Grave").find_each do |grave|
      grave.tags = tags
      grave.save!
    end

    redirect_to publications_path
  end

  def summary
    @data = @publication.figures.group(:type).count
      .map do |type, value|
        [if type == "Kurgan"
           "Burial Mound"
         elsif type == "Oxcal"
           "OxCal Diagram"
         elsif type == "Arrow"
           "Orientation Arrow"
         else
           type
         end, value]
      end.to_h
  end

  def radar
    @skeleton_angles = Stats.spine_angles(@publication.figures.where(type: "Spine").includes(grave: :arrow))
  end

  def stats # rubocop:disable Metrics/AbcSize
    marked_items = params.dig(:compare, :special_mark_graves)&.split("\n")&.map(&:to_i) || []
    @excluded_graves = params.dig(:compare, :exclude_graves)&.split("\n")&.map(&:to_i) || []
    @no_box = true
    graves = @publication.figures.where(type: "Grave").where("probability > 0.6").where.not(id: @excluded_graves)
    @skeleton_per_grave_type = graves.includes(:skeleton_figures).map { _1.skeleton_figures.length }.tally
    @skeleton_angles = Stats.spine_angles(@publication.figures.where(type: "Spine").includes(grave: :arrow))
    @grave_angles = Stats.grave_angles(graves.includes(:arrow))
    set_compare_graves

    @publications = [@publication, *@other_publications].reverse

    @outlines_pca_data, @outline_pca = Stats.outlines_pca([@publication, *@other_publications].reverse, special_objects: marked_items, excluded: @excluded_graves)
    @variances = Stats.pca_variance([@publication, *@other_publications].reverse, marked: marked_items, excluded: @excluded_graves)
    # @outline_variance_ratio = @outline_pca.explained_variance_ratio.to_a
    @outline_variance_ratio = []
    @graves_pca, @pca = Stats.graves_pca([@publication, *@other_publications].reverse, special_objects: marked_items,
      excluded: @excluded_graves)

    # @graves_pca_chart = Stats.pca_chart(@graves_pca)

    @base_spines_by_site = @publication.figures.where(type: "Spine").group_by { |spine| spine.grave.site }

    @spines_right = @publication.figures.where(type: "Spine")
      .filter { |spine| spine.skeleton.deposition_type == "right_side" }
    @spines_right = ArtefactsHeatmap.new.run(@spines_right)

    @spines_left = @publication.figures.where(type: "Spine")
      .filter { |spine| spine.skeleton.deposition_type == "left_side" }
    @spines_left = ArtefactsHeatmap.new.run(@spines_left)

    @spines_by_site_right = @base_spines_by_site.map do |site, spines|
      spines = spines.filter { _1.skeleton.deposition_type == "right_side" }
      [site, ArtefactsHeatmap.new.run(spines)]
    end.to_h.filter { |site, data| !data[:graves].empty? }

    @spines_by_site_left = @base_spines_by_site.map do |site, spines|
      [site, ArtefactsHeatmap.new.run(spines.filter { _1.skeleton.deposition_type == "left_side" })]
    end.to_h.filter { |site, data| !data[:graves].empty? }

    @outlines_data, _ = Stats.outlines_efd([@publication, *@other_publications].reverse, excluded: @excluded_graves)

    @colors = [
      [209, 41, 41],
      [129, 239, 19],
      [77, 209, 209],
      [115, 10, 219]
    ]
    @hex_colors = @colors.map do |color|
      "##{color[0].to_s(16)}#{color[1].to_s(16)}#{color[2].to_s(16)}"
    end
  end

  # GET /publications/new
  def new
    @publication = Publication.new
  end

  # GET /publications/1/edit
  def edit
  end

  def export_lithics
    @lithics = @publication.figures.where(type: "StoneTool").where("probability > ?", 0.6)

    render json: ExportLithics.new.export(@lithics)
  end

  def export
    ExportPublication.new.export(@publication)

    send_file "export.zip", filename: "#{@publication.short_description}.zip"
  end

  def analyze
    @publication = Publication.find(params[:id])

    AnalyzePublicationJob.perform_later Publication.first
  end

  # POST /publications or /publications.json
  def create # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    name = publication_params[:title]
    if name.empty?
      name = publication_params[:pdf].original_filename.gsub(".pdf", "")
    end

    @publication = Publication.new({
      author: publication_params[:author],
      title: name,
      pdf: publication_params[:pdf],
      year: publication_params[:year]
    })

    respond_to do |format|
      if @publication.save
        AnalyzePublicationJob.perform_later(@publication, site_id: publication_params[:site])

        format.html do
          redirect_to progress_publication_path(@publication)
        end
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def progress
  end

  # PATCH/PUT /publications/1 or /publications/1.json
  def update
    respond_to do |format|
      if @publication.update(publication_params)
        format.html { redirect_to publications_path, notice: "Publication was successfully updated." }
        format.json { render :show, status: :ok, location: @publication }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @publication.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /publications/1 or /publications/1.json
  def destroy
    @publication.destroy!

    respond_to do |format|
      format.html { redirect_to publications_url, notice: "Publication was successfully deleted." }
      format.json { head :no_content }
    end
  end

  def analysis
    @form = Forms::ArtefactAnalysisForm.new

    @colors = [
      [209, 41, 41],
      [129, 239, 19],
      [77, 209, 209],
      [115, 10, 219]
    ]
    @hex_colors = @colors.map do |color|
      "##{color[0].to_s(16)}#{color[1].to_s(16)}#{color[2].to_s(16)}"
    end

    if params[:forms_artefact_analysis_form].present?
      @form = Forms::ArtefactAnalysisForm.new(analysis_form_params)

      @artefact_type = {
        'Lithic' => StoneTool,
        'Ceramic' => Ceramic,
      }[@form.artefact_type]

      @figures = @publication.figures.includes(:scale).where(type: @artefact_type.name).order(:id)#.filter { _1.width_with_unit[:unit] != 'px' }
      @figures = @figures.filter { _1.contour.present? }

      contours = @figures.map(&:contour)
      return if contours.empty?
      frequencies = contours.map do |contour|
        Efd.elliptic_fourier_descriptors(contour, normalize: true, order: 15).to_a.flatten
      end

      @pca = Stats.efd_pca(frequencies)

      @pca_data = @pca.zip(@figures)
      @pca_data = [{
        name: @publication.short_description,
        data: @pca_data.map do |pca, figure|
          pca = Stats.convert_pca_item_to_polar(pca)
          pca.merge({ id: figure.id, title: figure.id, link: "/size_figures/#{figure.id}/update_size_figure/set_data" })
        end
      }]
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_publication
    @publication = Publication
      .select(:title, :author, :id, :year, :user_id, :public)
      .find(params[:id] || params[:publication_id])
  end

  def set_compare_graves
    @other_publications = params
      .dig(:compare, :publication_id)
      &.take(4)
      &.map { Publication.includes(:figures).find(_1) if _1.present? }
      &.compact
  end

  # Only allow a list of trusted parameters through.
  def publication_params
    params.require(:publication).permit(:pdf, :public, :author, :title, :year, shared_with_user_ids: [])
  end

  def analysis_form_params
    params.require(:forms_artefact_analysis_form).permit(:artefact_type)
  end
end
