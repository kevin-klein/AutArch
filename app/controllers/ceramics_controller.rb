class CeramicsController < ApplicationController
  def index
    @no_box = true
    @ceramics = Ceramic.where("figures.probability > 0.6").order(:id)

    if params.dig(:search, :publication_id).present?
      @ceramics = @ceramics
        .joins(page: :publication)
        .where({publication: {id: params.dig(:search, :publication_id)}})
    end

    if params.dig(:search, :linked_to_grave) == "1"
      @ceramics = @ceramics
        .includes(good: :grave)
        .joins(:good)
    end

    @ceramics_pagy, @ceramics = pagy(@ceramics.all)
  end

  def show
    @ceramic = Ceramic.find(params[:id])
  end

  def wizard
    @page = Page.find(params[:page_id]) if params[:page_id]
    @no_box = true  # Hide navbar for kiosk mode
    render template: 'ceramics/wizard'
  end
end
