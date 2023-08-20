class AddPercentageScaleToFigures < ActiveRecord::Migration[7.0]
  def change
    add_column :figures, :percentage_scale, :integer
    add_column :figures, :page_size, :integer
  end
end
