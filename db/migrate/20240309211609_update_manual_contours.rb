class UpdateManualContours < ActiveRecord::Migration[7.0]
  def change
    change_table :figures do |t|
      t.remove :bounding_box_center_x
      t.remove :bounding_box_center_y
      t.remove :bounding_box_width
      t.remove :bounding_box_height

      t.integer :control_point_1_x
      t.integer :control_point_1_y
      t.integer :control_point_2_x
      t.integer :control_point_2_y
      t.integer :control_point_3_x
      t.integer :control_point_3_y
      t.integer :control_point_4_x
      t.integer :control_point_4_y

      t.integer :anchor_point_1_x
      t.integer :anchor_point_1_y
      t.integer :anchor_point_2_x
      t.integer :anchor_point_2_y
      t.integer :anchor_point_3_x
      t.integer :anchor_point_3_y
      t.integer :anchor_point_4_x
      t.integer :anchor_point_4_y
    end
  end
end
