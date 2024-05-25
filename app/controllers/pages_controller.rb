class PagesController < ApplicationController
  before_action :set_publication
  before_action :set_page, only: %i[show edit update destroy]

  # GET /pages or /pages.json
  def index
    @pages = @publication.pages.order(:id)
    redirect_to publication_page_path(@publication, @pages.first)
  end

  # GET /pages/1 or /pages/1.json
  def show
  end

  # GET /pages/new
  def new
    @page = Page.new
  end

  # GET /pages/1/edit
  def edit
  end

  # POST /pages or /pages.json
  def create
    @page = Page.new(page_params)

    respond_to do |format|
      if @page.save
        format.html { redirect_to page_url(@page), notice: "Page was successfully created." }
        format.json { render :show, status: :created, location: @page }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pages/1 or /pages/1.json
  def update
    respond_to do |format|
      Figure.update(params[:figures].keys, params[:figures].values).reject { |p| p.errors.empty? }

      if Figure.update(params[:figures].keys, params[:figures].values).reject { |p| p.errors.empty? }
        format.html { redirect_to publication_page_path(@publication, @page), notice: "Page was successfully updated." }
        format.json { render :show, status: :ok, location: @page }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pages/1 or /pages/1.json
  def destroy
    @page.destroy

    respond_to do |format|
      format.html { redirect_to pages_url, notice: "Page was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_page
    @page = @publication.pages.find(params[:id])
  end

  def set_publication
    @publication = Publication.find(params[:publication_id])
  end

  # Only allow a list of trusted parameters through.
  def page_params
    params.require(:page).permit(:publication_id, :number, :image_id)
  end
end
