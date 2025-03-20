class AddEfdsToFigures < ActiveRecord::Migration[7.0]
  def change
    add_column :figures, :efds, :float, array: true, default: [], null: false
  end
end
