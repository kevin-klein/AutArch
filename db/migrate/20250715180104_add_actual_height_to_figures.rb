class AddActualHeightToFigures < ActiveRecord::Migration[7.0]
  def change
    add_column :figures, :actual_height_mm, :integer
  end
end
