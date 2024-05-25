class GeneticsController < ApplicationController
  before_action :set_genetic, only: %i[show edit update destroy]

  # GET /genetics or /genetics.json
  def index
    @genetics = Genetic.all
  end

  # GET /genetics/1 or /genetics/1.json
  def show
  end

  # GET /genetics/new
  def new
    @genetic = Genetic.new
  end

  # GET /genetics/1/edit
  def edit
  end

  # POST /genetics or /genetics.json
  def create
    @genetic = Genetic.new(genetic_params)

    respond_to do |format|
      if @genetic.save
        format.html { redirect_to genetic_url(@genetic), notice: "Genetic was successfully created." }
        format.json { render :show, status: :created, location: @genetic }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @genetic.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /genetics/1 or /genetics/1.json
  def update
    respond_to do |format|
      if @genetic.update(genetic_params)
        format.html { redirect_to genetic_url(@genetic), notice: "Genetic was successfully updated." }
        format.json { render :show, status: :ok, location: @genetic }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @genetic.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /genetics/1 or /genetics/1.json
  def destroy
    @genetic.destroy

    respond_to do |format|
      format.html { redirect_to genetics_url, notice: "Genetic was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_genetic
    @genetic = Genetic.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def genetic_params
    params.require(:genetic).permit(:data_type, :end_content, :ref_gen, :skeleton_id)
  end
end
