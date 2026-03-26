class KioskConfigsController < ApplicationController
  before_action :set_global_kiosk_config, only: %i[ show ]
  before_action :require_user

  # GET /kiosk_config.json
  def show
    respond_to do |format|
      format.json do
        render json: {
          id: @kiosk_config.id,
          page_id: @kiosk_config.page_id,
          figure_id: @kiosk_config.figure_id,
          page: @kiosk_config.page,
          figure: @kiosk_config.figure,
          publication_id: @kiosk_config.page&.publication_id,
          figure: @kiosk_config.figure,
          figures: @kiosk_config.page.figures.where(type: 'Ceramic')
        }
      end
    end
  end

  # GET /kiosk_config/frontend
  def kiosk_config_frontend
    @kiosk_config = KioskConfig.first || KioskConfig.new
  end

  # GET /kiosk_config
  def kiosk_config
    @kiosk_config = KioskConfig.first || KioskConfig.new
  end

  # POST /kiosk_config.json
  def create
    @kiosk_config = KioskConfig.first_or_initialize

    respond_to do |format|
      if @kiosk_config.update(kiosk_config_params)
        format.json { render json: { success: true, kiosk_config: @kiosk_config }, status: :ok }
      else
        format.json { render json: { success: false, errors: @kiosk_config.errors }, status: :unprocessable_entity }
      end
    end
  end

  def publications
    respond_to do |format|
      format.json do
        publications = Publication.all.order(title: :asc)

        render json: (publications.map do |publication|
          {
            id: publication.id,
            title: publication.title,
            author: publication.author,
          }
        end)
      end
    end
  end

  # GET /kiosk_config/pages.json
  def pages
    respond_to do |format|
      format.json do
        pages = Page.joins(:publication)
          .where(publications: { id: params[:publication_id] })
          .includes(:publication, :image, figures: [:page])
          .order(publications: {title: :asc}, pages: {number: :asc})

        render json: pages.map do |page|
          {
            id: page.id,
            page_number: page.number,
            image_url: rails_blob_path(page.image, only_path: true),
            figures: figures
          }
        end
      end
    end
  end

  # GET /kiosk_config/pages/:id/figures.json
  def page_figures
    page = Page.find(params[:id])

    respond_to do |format|
      format.json do
        figures = page.figures.where('probability > ?', 0.6).order(id: :asc)
          .map do |figure|
            {
              id: figure.id,
              type: figure.type,
              x1: figure.x1,
              y1: figure.y1,
              x2: figure.x2,
              y2: figure.y2,
              probability: figure.probability,
              identifier: figure.identifier,
              text: figure.text,
              contour: figure.contour,
              image_url: preview_figure_path(figure)
            }
          end

        render json: figures
      end
    end
  end

  # GET /kiosk_configs/select_ceramic
  def select_ceramic
    @kiosk_config = KioskConfig.first || KioskConfig.new
  end

  private

  def set_global_kiosk_config
    @kiosk_config = KioskConfig.first || KioskConfig.new
  end

  def require_user
    unless current_user
      respond_to do |format|
        format.json { render json: { error: 'You must be logged in' }, status: :unauthorized }
        format.html { redirect_to '/login', alert: 'You must be logged in' }
      end
    end
  end

  def kiosk_config_params
    params.require(:kiosk_config).permit(:page_id, :figure_id)
  end
end
