class AddAreaToGraves < ActiveRecord::Migration[7.0]
  def change
    add_column :graves, :area, :float
  end
end
