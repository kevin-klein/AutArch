class AddTextToFigures < ActiveRecord::Migration[7.0]
  def change
    add_column :figures, :text, :string
  end
end
