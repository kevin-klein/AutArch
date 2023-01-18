class AddFieldsToSites < ActiveRecord::Migration[7.0]
  def change
    change_table :sites do |t|
      t.string :locality
      t.integer :country_code
      t.string :site_code
    end
  end
end
