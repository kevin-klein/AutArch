class RenameSkeletons < ActiveRecord::Migration[7.0]
  def change
    create_table :skeleton_figures do |t|
      t.references :figure
      t.references :grave
      t.references :skeleton
    end

    change_table :skeletons do |t|
      t.references :skeleton_figure
    end

    Skeleton.find_each do |skeleton|
      SkeletonFigure.create!(
        skeleton: skeleton,
        grave: skeleton.grave,
        figure: skeleton.figure
      )
    end
  end
end
