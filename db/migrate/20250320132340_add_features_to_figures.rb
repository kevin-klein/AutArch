class AddFeaturesToFigures < ActiveRecord::Migration[7.0]
  def change
    add_column :figures, :features, :float, array: true, default: [], null: false
  end
end
