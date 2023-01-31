class BonesController < ApplicationController
  before_action :set_bone, only: %i[show edit update destroy]

  # GET /bones or /bones.json
  def index
    @bones = Bone.all
  end

  # GET /bones/1 or /bones/1.json
  def show; end

  # GET /bones/new
  def new
    @bone = Bone.new
  end

  # GET /bones/1/edit
  def edit; end

  # POST /bones or /bones.json
  def create
    @bone = Bone.new(bone_params)

    respond_to do |format|
      if @bone.save
        format.html { redirect_to bone_url(@bone), notice: 'Bone was successfully created.' }
        format.json { render :show, status: :created, location: @bone }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @bone.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bones/1 or /bones/1.json
  def update
    respond_to do |format|
      if @bone.update(bone_params)
        format.html { redirect_to bone_url(@bone), notice: 'Bone was successfully updated.' }
        format.json { render :show, status: :ok, location: @bone }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @bone.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bones/1 or /bones/1.json
  def destroy
    @bone.destroy

    respond_to do |format|
      format.html { redirect_to bones_url, notice: 'Bone was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_bone
    @bone = Bone.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def bone_params
    params.require(:bone).permit(:name)
  end
end
