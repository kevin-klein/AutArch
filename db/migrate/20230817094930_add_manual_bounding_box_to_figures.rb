class AddManualBoundingBoxToFigures < ActiveRecord::Migration[7.0]
  def change
    change_table :figures do |t|
      t.boolean :manual_bounding_box, default: false
      t.integer :bounding_box_center_x
      t.integer :bounding_box_center_y
      t.integer :bounding_box_angle
      t.integer :bounding_box_width
      t.integer :bounding_box_height
    end
  end
end
