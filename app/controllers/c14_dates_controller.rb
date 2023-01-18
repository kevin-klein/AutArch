class C14DatesController < ApplicationController
  before_action :set_c14_date, only: %i[ show edit update destroy ]

  # GET /c14_dates or /c14_dates.json
  def index
    @c14_dates = C14Date.all
  end

  # GET /c14_dates/1 or /c14_dates/1.json
  def show
  end

  # GET /c14_dates/new
  def new
    @c14_date = C14Date.new
  end

  # GET /c14_dates/1/edit
  def edit
  end

  # POST /c14_dates or /c14_dates.json
  def create
    @c14_date = C14Date.new(c14_date_params)

    respond_to do |format|
      if @c14_date.save
        format.html { redirect_to c14_date_url(@c14_date), notice: "C14 date was successfully created." }
        format.json { render :show, status: :created, location: @c14_date }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @c14_date.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /c14_dates/1 or /c14_dates/1.json
  def update
    respond_to do |format|
      if @c14_date.update(c14_date_params)
        format.html { redirect_to c14_date_url(@c14_date), notice: "C14 date was successfully updated." }
        format.json { render :show, status: :ok, location: @c14_date }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @c14_date.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /c14_dates/1 or /c14_dates/1.json
  def destroy
    @c14_date.destroy

    respond_to do |format|
      format.html { redirect_to c14_dates_url, notice: "C14 date was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_c14_date
      @c14_date = C14Date.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def c14_date_params
      params.require(:c14_date).permit(:c14_type, :lab_id, :age_bp, :interval, :material, :calbc_1sigma_max, :calbc_1_sigma_min, :calbc_2sigma_max, :calbc_2sigma_min, :date_note, :cal_method, :ref_14c)
    end
end
