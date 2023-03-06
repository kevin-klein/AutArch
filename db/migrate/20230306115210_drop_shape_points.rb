class DropShapePoints < ActiveRecord::Migration[7.0]
  def change
    drop_table :shape_points
  end
end
