class TaxonomiesController < ApplicationController
  before_action :set_taxonomy, only: %i[show edit update destroy]

  # GET /taxonomies or /taxonomies.json
  def index
    @taxonomies = Taxonomy.all
  end

  # GET /taxonomies/1 or /taxonomies/1.json
  def show
  end

  # GET /taxonomies/new
  def new
    @taxonomy = Taxonomy.new
  end

  # GET /taxonomies/1/edit
  def edit
  end

  # POST /taxonomies or /taxonomies.json
  def create
    @taxonomy = Taxonomy.new(taxonomy_params)

    respond_to do |format|
      if @taxonomy.save
        format.html { redirect_to taxonomy_url(@taxonomy), notice: "Taxonomy was successfully created." }
        format.json { render :show, status: :created, location: @taxonomy }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @taxonomy.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /taxonomies/1 or /taxonomies/1.json
  def update
    respond_to do |format|
      if @taxonomy.update(taxonomy_params)
        format.html { redirect_to taxonomy_url(@taxonomy), notice: "Taxonomy was successfully updated." }
        format.json { render :show, status: :ok, location: @taxonomy }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @taxonomy.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /taxonomies/1 or /taxonomies/1.json
  def destroy
    @taxonomy.destroy

    respond_to do |format|
      format.html { redirect_to taxonomies_url, notice: "Taxonomy was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_taxonomy
    @taxonomy = Taxonomy.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def taxonomy_params
    params.require(:taxonomy).permit(:culture, :culture_note, :culture_reference)
  end
end
