class AddContourInfo < ActiveRecord::Migration[7.0]
  def change
    add_column :figures, :contour_info, :jsonb
  end
end
