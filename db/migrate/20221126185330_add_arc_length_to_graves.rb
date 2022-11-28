class AddArcLengthToGraves < ActiveRecord::Migration[7.0]
  def change
    add_column :graves, :arc_length, :float
  end
end
