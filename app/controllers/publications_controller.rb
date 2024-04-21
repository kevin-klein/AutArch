class PublicationsController < ApplicationController
  before_action :set_publication, only: %i[progress summary show edit update destroy stats]

  # GET /publications or /publications.json
  def index
    @publications = Publication.select(:id, :title, :author, :year).order(:created_at)
  end

  # GET /publications/1 or /publications/1.json
  def show
    @publication
  end

  def summary
    @data = @publication.figures.group(:type).count
  end

  def stats # rubocop:disable Metrics/AbcSize
    marked_items = params.dig(:compare, :special_mark_graves)&.split("\n")&.map(&:to_i) || []
    @excluded_graves = params.dig(:compare, :exclude_graves)&.split("\n")&.map(&:to_i) || []
    @no_box = true
    graves = @publication.figures.where(type: 'Grave').where.not(id: @excluded_graves)
    @skeleton_per_grave_type = graves.includes(:skeleton_figures).map { _1.skeleton_figures.length }.tally
    @skeleton_angles = Stats.spine_angles(@publication.figures.where(type: 'Spine').includes(grave: :arrow))
    @grave_angles = Stats.grave_angles(graves.includes(:arrow))
    set_compare_graves

    @publications = [@publication, *@other_publications]

    if @publications.length == 2
      @all_skeleton_angles = @publications.map do |publication|
        publication.figures.where(type: 'Spine')
          .includes(grave: :arrow)
          # .sample(6)
          .map { [_1, _1.grave&.arrow] }
          .filter { |_spine, arrow| arrow.present? }
          .map { |spine, arrow| spine.angle_with_arrow(arrow) }
      end

      @u_result = Stats.mannwhitneyu(*@all_skeleton_angles)
      # raise
    end

    @outlines_pca_data, @outline_pca = Stats.outlines_pca([@publication, *@other_publications], special_objects: marked_items, excluded: @excluded_graves)
    @variances = Stats.pca_variance([@publication, *@other_publications], marked: marked_items, excluded: @excluded_graves)
    @outline_variance_ratio = @outline_pca.explained_variance_ratio.to_a
    @graves_pca, @pca = Stats.graves_pca([@publication, *@other_publications], special_objects: marked_items,
      excluded: @excluded_graves)

    # @graves_pca_chart = Stats.pca_chart(@graves_pca)

    @outlines_data, _ = Stats.outlines_efd([@publication, *@other_publications], excluded: @excluded_graves)

    upgma_result = Stats.upgma(@outlines_data)
    @upgma_figure = Stats.upgma_figure(upgma_result)

    @cluster_upgma_chart = Stats.cluster_scatter_chart(@outlines_data, upgma_result)

    ward_result = Stats.ward(@outlines_data)
    @ward_figure = Stats.upgma_figure(ward_result)

    @cluster_ward_chart = Stats.cluster_scatter_chart(@outlines_data, ward_result)

    # @clustering_result = Upgma.cluster(@outlines_pca_data.map do |item|
    #   item[:data].map { [_1[:x], _1[:y]] }
    # end.flatten(1).map { [_1] }, 10).map do |cluster|
    #   {
    #     data: cluster.map { { x: _1[0], y: _1[1] } }
    #   }
    # end

    @efd_pca_chart = Stats.pca_chart(@outlines_pca_data)
    @colors = [
      [209, 41, 41],
      [129, 239, 19],
      [77, 209, 209],
      [115, 10, 219]
    ]
  end

  # GET /publications/new
  def new
    @publication = Publication.new
  end

  # GET /publications/1/edit
  def edit; end

  def analyze
    @publication = Publication.find(params[:id])

    AnalyzePublicationJob.perform_later Publication.first
  end

  # POST /publications or /publications.json
  def create # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    @publication = Publication.new({
                                     author: publication_params[:author],
                                     title: publication_params[:title],
                                     pdf: publication_params[:pdf],
                                     year: publication_params[:year]
                                   })

    respond_to do |format|
      if @publication.save
        AnalyzePublicationJob.perform_later(@publication, site_id: publication_params[:site])

        format.html do
          redirect_to progress_publication_path(@publication), notice: 'Publication was successfully created.'
        end
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def progress; end

  # PATCH/PUT /publications/1 or /publications/1.json
  def update
    respond_to do |format|
      if @publication.update(publication_params)
        format.html { redirect_to publications_path, notice: 'Publication was successfully updated.' }
        format.json { render :show, status: :ok, location: @publication }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @publication.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /publications/1 or /publications/1.json
  def destroy
    @publication.destroy

    respond_to do |format|
      format.html { redirect_to publications_url, notice: 'Publication was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_publication
    @publication = Publication
                   .select(:title, :author, :id, :year)
                   .find(params[:id] || params[:publication_id])
  end

  def set_compare_graves
    @other_publications = params
                          .dig(:compare, :publication_id)
      &.map { Publication.includes(:figures).find(_1) if _1.present? }
                          &.compact
  end

  # Only allow a list of trusted parameters through.
  def publication_params
    params.require(:publication).permit(:pdf, :author, :title, :site, :year)
  end
end
