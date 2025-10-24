class AddInternmentTypeToFigures < ActiveRecord::Migration[7.0]
  def change
    add_column :figures, :internment_type, :integer
  end
end
