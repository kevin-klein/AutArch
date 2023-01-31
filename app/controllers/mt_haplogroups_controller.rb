class MtHaplogroupsController < ApplicationController
  before_action :set_mt_haplogroup, only: %i[show edit update destroy]

  # GET /mt_haplogroups or /mt_haplogroups.json
  def index
    @mt_haplogroups = MtHaplogroup.all
  end

  # GET /mt_haplogroups/1 or /mt_haplogroups/1.json
  def show; end

  # GET /mt_haplogroups/new
  def new
    @mt_haplogroup = MtHaplogroup.new
  end

  # GET /mt_haplogroups/1/edit
  def edit; end

  # POST /mt_haplogroups or /mt_haplogroups.json
  def create
    @mt_haplogroup = MtHaplogroup.new(mt_haplogroup_params)

    respond_to do |format|
      if @mt_haplogroup.save
        format.html { redirect_to mt_haplogroup_url(@mt_haplogroup), notice: 'Mt haplogroup was successfully created.' }
        format.json { render :show, status: :created, location: @mt_haplogroup }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @mt_haplogroup.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mt_haplogroups/1 or /mt_haplogroups/1.json
  def update
    respond_to do |format|
      if @mt_haplogroup.update(mt_haplogroup_params)
        format.html { redirect_to mt_haplogroup_url(@mt_haplogroup), notice: 'Mt haplogroup was successfully updated.' }
        format.json { render :show, status: :ok, location: @mt_haplogroup }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @mt_haplogroup.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mt_haplogroups/1 or /mt_haplogroups/1.json
  def destroy
    @mt_haplogroup.destroy

    respond_to do |format|
      format.html { redirect_to mt_haplogroups_url, notice: 'Mt haplogroup was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_mt_haplogroup
    @mt_haplogroup = MtHaplogroup.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def mt_haplogroup_params
    params.require(:mt_haplogroup).permit(:name)
  end
end
