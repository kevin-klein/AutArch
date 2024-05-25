class StableIsotopesController < ApplicationController
  before_action :set_stable_isotope, only: %i[show edit update destroy]

  # GET /stable_isotopes or /stable_isotopes.json
  def index
    @stable_isotopes = StableIsotope.all
  end

  # GET /stable_isotopes/1 or /stable_isotopes/1.json
  def show
  end

  # GET /stable_isotopes/new
  def new
    @stable_isotope = StableIsotope.new
  end

  # GET /stable_isotopes/1/edit
  def edit
  end

  # POST /stable_isotopes or /stable_isotopes.json
  def create
    @stable_isotope = StableIsotope.new(stable_isotope_params)

    respond_to do |format|
      if @stable_isotope.save
        format.html do
          redirect_to stable_isotope_url(@stable_isotope), notice: "Stable isotope was successfully created."
        end
        format.json { render :show, status: :created, location: @stable_isotope }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @stable_isotope.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stable_isotopes/1 or /stable_isotopes/1.json
  def update
    respond_to do |format|
      if @stable_isotope.update(stable_isotope_params)
        format.html do
          redirect_to stable_isotope_url(@stable_isotope), notice: "Stable isotope was successfully updated."
        end
        format.json { render :show, status: :ok, location: @stable_isotope }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @stable_isotope.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stable_isotopes/1 or /stable_isotopes/1.json
  def destroy
    @stable_isotope.destroy

    respond_to do |format|
      format.html { redirect_to stable_isotopes_url, notice: "Stable isotope was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_stable_isotope
    @stable_isotope = StableIsotope.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def stable_isotope_params
    params.require(:stable_isotope).permit(:skeleton_id, :iso_id, :iso_bone, :iso_value, :ref_iso, :isotope,
      :baseline)
  end
end
