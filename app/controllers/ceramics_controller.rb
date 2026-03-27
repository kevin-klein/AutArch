class CeramicsController < ApplicationController
  def index
    @no_box = true
    @ceramics = Ceramic.where("figures.probability > 0.6").order(:id)
    @kiosk_config = KioskConfig.first
    @kiosk_config = {
      id: @kiosk_config.id,
      page_id: @kiosk_config.page_id,
      figure_id: @kiosk_config.figure_id,
      page: @kiosk_config.page,
      image: @kiosk_config.page.image.url,
      figure: @kiosk_config.figure,
      publication_id: @kiosk_config.page&.publication_id,
      figure: @kiosk_config.figure,
      figures: @kiosk_config.page.figures.where(type: 'Ceramic').as_json(include: :site),
      sites: Site.all,
      three_d_model: rails_blob_path(@kiosk_config.figure.three_d_model)
    }

    render template: 'ceramics/wizard'
  end

  def show
    @ceramic = Ceramic.find(params[:id])
  end

  # GET /ceramics/:id/similarities.json
  def similarities
    @ceramic = Ceramic.find(params[:id])

    # Get the publication this ceramic belongs to
    @publication = @ceramic.page&.publication

    unless @publication
      render json: { error: "Ceramic does not belong to a publication" }, status: :not_found
      return
    end

    # Get all other ceramics from the same publication with probability > 0.6
    @similar_ceramics = @publication.figures
      .where(type: "Ceramic")
      .where("figures.probability > 0.6")
      .where.not(id: @ceramic.id)
      .order(:id)
      .includes(:page, :site)

    # Get similarities for this ceramic
    @similarities = @ceramic.similarities_as_first.to_a

    # Build response with similarity data
    @similarity_data = @similar_ceramics.map do |ceramic|
      similarity_record = @similarities.find { |s| s.second_id == ceramic.id }
      {
        id: ceramic.id,
        identifier: ceramic.identifier,
        type: ceramic.type,
        probability: ceramic.probability,
        similarity: similarity_record&.similarity || 0.0,
        page_number: ceramic.page&.number,
        site: ceramic.site&.as_json(select: [:id, :name]) #if ceramic.site.present?
      }
    end

    # Sort by similarity (highest first)
    @similarity_data.sort_by! { |data| -data[:similarity] }

    respond_to do |format|
      format.json do
        render json: {
          ceramic: {
            id: @ceramic.id,
            identifier: @ceramic.identifier,
            type: @ceramic.type,
            probability: @ceramic.probability,
            page_number: @ceramic.page&.number,
            site: @ceramic.site&.as_json(select: [:id, :name]) #if @ceramic.site.present?
          },
          publication: {
            id: @publication.id,
            title: @publication.title,
            author: @publication.author
          },
          similarities: @similarity_data,
          total_similar: @similarity_data.length,
          max_similarity: @similarity_data.first&.dig(:similarity) || 0.0
        }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_ceramic
    @ceramic = Ceramic.find(params[:id])
  end
end
