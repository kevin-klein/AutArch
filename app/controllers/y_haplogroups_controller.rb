class YHaplogroupsController < ApplicationController
  before_action :set_y_haplogroup, only: %i[ show edit update destroy ]

  # GET /y_haplogroups or /y_haplogroups.json
  def index
    @y_haplogroups = YHaplogroup.all
  end

  # GET /y_haplogroups/1 or /y_haplogroups/1.json
  def show
  end

  # GET /y_haplogroups/new
  def new
    @y_haplogroup = YHaplogroup.new
  end

  # GET /y_haplogroups/1/edit
  def edit
  end

  # POST /y_haplogroups or /y_haplogroups.json
  def create
    @y_haplogroup = YHaplogroup.new(y_haplogroup_params)

    respond_to do |format|
      if @y_haplogroup.save
        format.html { redirect_to y_haplogroup_url(@y_haplogroup), notice: "Y haplogroup was successfully created." }
        format.json { render :show, status: :created, location: @y_haplogroup }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @y_haplogroup.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /y_haplogroups/1 or /y_haplogroups/1.json
  def update
    respond_to do |format|
      if @y_haplogroup.update(y_haplogroup_params)
        format.html { redirect_to y_haplogroup_url(@y_haplogroup), notice: "Y haplogroup was successfully updated." }
        format.json { render :show, status: :ok, location: @y_haplogroup }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @y_haplogroup.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /y_haplogroups/1 or /y_haplogroups/1.json
  def destroy
    @y_haplogroup.destroy

    respond_to do |format|
      format.html { redirect_to y_haplogroups_url, notice: "Y haplogroup was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_y_haplogroup
      @y_haplogroup = YHaplogroup.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def y_haplogroup_params
      params.require(:y_haplogroup).permit(:name)
    end
end
