class AddSkeletonAttributes < ActiveRecord::Migration[7.0]
  def change
    change_table :skeletons do |t|
      t.string :skeleton_id
    end

    change_table :spines do |t|
      t.references :skeleton
    end

    CreateGraves.new.assign_spines_to_skeletons
  end
end
