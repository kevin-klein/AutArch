class GravesController < ApplicationController
  before_action :set_grafe, only: %i[ show edit update destroy ]

  # GET /graves or /graves.json
  def index
    @graves = Grave.all
  end

  # GET /graves/1 or /graves/1.json
  def show
  end

  # GET /graves/new
  def new
    @grafe = Grave.new
  end

  # GET /graves/1/edit
  def edit
  end

  # POST /graves or /graves.json
  def create
    @grafe = Grave.new(grafe_params)

    respond_to do |format|
      if @grafe.save
        format.html { redirect_to grafe_url(@grafe), notice: "Grave was successfully created." }
        format.json { render :show, status: :created, location: @grafe }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @grafe.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /graves/1 or /graves/1.json
  def update
    respond_to do |format|
      if @grafe.update(grafe_params)
        format.html { redirect_to grafe_url(@grafe), notice: "Grave was successfully updated." }
        format.json { render :show, status: :ok, location: @grafe }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @grafe.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /graves/1 or /graves/1.json
  def destroy
    @grafe.destroy

    respond_to do |format|
      format.html { redirect_to graves_url, notice: "Grave was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_grafe
      @grafe = Grave.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def grafe_params
      params.require(:grafe).permit(:location, :figure_id)
    end
end
