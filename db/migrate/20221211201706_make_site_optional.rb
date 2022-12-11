class MakeSiteOptional < ActiveRecord::Migration[7.0]
  def change
    change_column :graves, :site_id, :integer, null: true
  end
end
