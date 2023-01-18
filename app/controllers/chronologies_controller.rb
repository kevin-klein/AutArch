class ChronologiesController < ApplicationController
  before_action :set_chronology, only: %i[ show edit update destroy ]

  # GET /chronologies or /chronologies.json
  def index
    @chronologies = Chronology.all
  end

  # GET /chronologies/1 or /chronologies/1.json
  def show
  end

  # GET /chronologies/new
  def new
    @chronology = Chronology.new
  end

  # GET /chronologies/1/edit
  def edit
  end

  # POST /chronologies or /chronologies.json
  def create
    @chronology = Chronology.new(chronology_params)

    respond_to do |format|
      if @chronology.save
        format.html { redirect_to chronology_url(@chronology), notice: "Chronology was successfully created." }
        format.json { render :show, status: :created, location: @chronology }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @chronology.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /chronologies/1 or /chronologies/1.json
  def update
    respond_to do |format|
      if @chronology.update(chronology_params)
        format.html { redirect_to chronology_url(@chronology), notice: "Chronology was successfully updated." }
        format.json { render :show, status: :ok, location: @chronology }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @chronology.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /chronologies/1 or /chronologies/1.json
  def destroy
    @chronology.destroy

    respond_to do |format|
      format.html { redirect_to chronologies_url, notice: "Chronology was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_chronology
      @chronology = Chronology.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def chronology_params
      params.require(:chronology).permit(:period, :context_from, :context_to)
    end
end
