class PeriodsController < ApplicationController
  before_action :set_period, only: %i[ show edit update destroy ]

  # GET /periods or /periods.json
  def index
    @periods = Period.all
  end

  # GET /periods/1 or /periods/1.json
  def show
  end

  # GET /periods/new
  def new
    @period = Period.new
  end

  # GET /periods/1/edit
  def edit
  end

  # POST /periods or /periods.json
  def create
    @period = Period.new(period_params)

    respond_to do |format|
      if @period.save
        format.html { redirect_to period_url(@period), notice: "Period was successfully created." }
        format.json { render :show, status: :created, location: @period }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @period.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /periods/1 or /periods/1.json
  def update
    respond_to do |format|
      if @period.update(period_params)
        format.html { redirect_to period_url(@period), notice: "Period was successfully updated." }
        format.json { render :show, status: :ok, location: @period }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @period.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /periods/1 or /periods/1.json
  def destroy
    @period.destroy

    respond_to do |format|
      format.html { redirect_to periods_url, notice: "Period was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_period
      @period = Period.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def period_params
      params.require(:period).permit(:name)
    end
end
