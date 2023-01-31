class SkeletonsController < ApplicationController
  def index
    @skeletons = Skeleton.all
  end

  def edit
    @skeleton = Skeleton.find(params[:id])
    @skeleton.build_chronology if @skeleton.chronology.nil?
    @skeleton.build_taxonomy if @skeleton.taxonomy.nil?
    @skeleton.build_anthropology if @skeleton.anthropology.nil?
  end

  def update
    respond_to do |format|
      @skeleton = Skeleton.find(params[:id])

      if @skeleton.update(skeleton_params)
        format.html { redirect_to edit_skeleton_path(@skeleton), notice: 'Stable isotope was successfully updated.' }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def skeleton_params
    params.require(:skeleton).permit(
      chronology: %i[
        context_from
        context_to
      ]
    )
  end
end
