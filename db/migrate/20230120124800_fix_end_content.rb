class FixEndContent < ActiveRecord::Migration[7.0]
  def change
    rename_column :genetics, :end_content, :endo_content
  end
end
