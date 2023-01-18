class CulturesController < ApplicationController
  before_action :set_culture, only: %i[ show edit update destroy ]

  # GET /cultures or /cultures.json
  def index
    @cultures = Culture.all
  end

  # GET /cultures/1 or /cultures/1.json
  def show
  end

  # GET /cultures/new
  def new
    @culture = Culture.new
  end

  # GET /cultures/1/edit
  def edit
  end

  # POST /cultures or /cultures.json
  def create
    @culture = Culture.new(culture_params)

    respond_to do |format|
      if @culture.save
        format.html { redirect_to culture_url(@culture), notice: "Culture was successfully created." }
        format.json { render :show, status: :created, location: @culture }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @culture.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cultures/1 or /cultures/1.json
  def update
    respond_to do |format|
      if @culture.update(culture_params)
        format.html { redirect_to culture_url(@culture), notice: "Culture was successfully updated." }
        format.json { render :show, status: :ok, location: @culture }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @culture.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cultures/1 or /cultures/1.json
  def destroy
    @culture.destroy

    respond_to do |format|
      format.html { redirect_to cultures_url, notice: "Culture was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_culture
      @culture = Culture.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def culture_params
      params.require(:culture).permit(:name)
    end
end
