class AddDummyToFigures < ActiveRecord::Migration[7.0]
  def change
    add_column :figures, :dummy, :boolean, null: false, default: false
  end
end
