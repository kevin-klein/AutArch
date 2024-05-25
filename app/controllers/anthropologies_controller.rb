class AnthropologiesController < ApplicationController
  before_action :set_anthropology, only: %i[show edit update destroy]

  # GET /anthropologies or /anthropologies.json
  def index
    @anthropologies = Anthropology.all
  end

  # GET /anthropologies/1 or /anthropologies/1.json
  def show
  end

  # GET /anthropologies/new
  def new
    @anthropology = Anthropology.new
  end

  # GET /anthropologies/1/edit
  def edit
  end

  # POST /anthropologies or /anthropologies.json
  def create
    @anthropology = Anthropology.new(anthropology_params)

    respond_to do |format|
      if @anthropology.save
        format.html { redirect_to anthropology_url(@anthropology), notice: "Anthropology was successfully created." }
        format.json { render :show, status: :created, location: @anthropology }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @anthropology.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /anthropologies/1 or /anthropologies/1.json
  def update
    respond_to do |format|
      if @anthropology.update(anthropology_params)
        format.html { redirect_to anthropology_url(@anthropology), notice: "Anthropology was successfully updated." }
        format.json { render :show, status: :ok, location: @anthropology }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @anthropology.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /anthropologies/1 or /anthropologies/1.json
  def destroy
    @anthropology.destroy

    respond_to do |format|
      format.html { redirect_to anthropologies_url, notice: "Anthropology was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_anthropology
    @anthropology = Anthropology.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def anthropology_params
    params.require(:anthropology).permit(:sex_morph, :sex_gen, :sex_consensus, :age_as_reported, :age_class, :height,
      :pathologies, :pathologies_type)
  end
end
