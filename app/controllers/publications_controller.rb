class PublicationsController < ApplicationController
  before_action :set_publication, only: %i[show edit update destroy stats]

  # GET /publications or /publications.json
  def index
    @publications = Publication.select(:id, :title, :author, :year).all
  end

  # GET /publications/1 or /publications/1.json
  def show
    @publication
  end

  def stats # rubocop:disable Metrics/AbcSize
    @no_box = true
    graves = @publication.figures.where(type: 'Grave')
    @skeleton_per_grave_type = graves.includes(:skeleton_figures).map { _1.skeleton_figures.length }.tally
    @skeleton_angles = Stats.spine_angles(@publication.figures.where(type: 'Spine').includes(grave: :arrow))
    @grave_angles = Stats.grave_angles(graves.includes(:arrow))
    set_compare_graves
    @variances = Stats.pca_variance([@publication, *@other_publications])
    @graves_pca, @pca = Stats.graves_pca([@publication, *@other_publications],
                                         special_objects: params.dig(:compare,
                                                                     :special_mark_graves)&.split("\n")&.map(&:to_i) || [])
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
                                     pdf: publication_params[:pdf].read
                                   })

    respond_to do |format|
      if @publication.save
        AnalyzePublicationJob.perform_later(@publication, site_id: publication_params[:site])

        format.html { redirect_to publications_path, notice: 'Publication was successfully created.' }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

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
      &.map { Publication.find(_1) if _1.present? }
                          &.compact
  end

  # Only allow a list of trusted parameters through.
  def publication_params
    params.require(:publication).permit(:pdf, :author, :title, :site, :year)
  end
end
