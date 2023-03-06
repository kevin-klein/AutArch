class ChangePoints < ActiveRecord::Migration[7.0]
  def change
    add_column :figures, :contour, :point, array: true, default: [], null: false
  end
end
