class KurgansController < ApplicationController
  before_action :set_kurgan, only: %i[ show edit update destroy ]

  # GET /kurgans or /kurgans.json
  def index
    @kurgans = Kurgan.all
  end

  # GET /kurgans/1 or /kurgans/1.json
  def show
  end

  # GET /kurgans/new
  def new
    @kurgan = Kurgan.new
  end

  # GET /kurgans/1/edit
  def edit
  end

  # POST /kurgans or /kurgans.json
  def create
    @kurgan = Kurgan.new(kurgan_params)

    respond_to do |format|
      if @kurgan.save
        format.html { redirect_to kurgan_url(@kurgan), notice: "Kurgan was successfully created." }
        format.json { render :show, status: :created, location: @kurgan }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @kurgan.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /kurgans/1 or /kurgans/1.json
  def update
    respond_to do |format|
      if @kurgan.update(kurgan_params)
        format.html { redirect_to kurgan_url(@kurgan), notice: "Kurgan was successfully updated." }
        format.json { render :show, status: :ok, location: @kurgan }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @kurgan.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /kurgans/1 or /kurgans/1.json
  def destroy
    @kurgan.destroy

    respond_to do |format|
      format.html { redirect_to kurgans_url, notice: "Kurgan was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_kurgan
      @kurgan = Kurgan.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def kurgan_params
      params.require(:kurgan).permit(:width, :height, :name)
    end
end
