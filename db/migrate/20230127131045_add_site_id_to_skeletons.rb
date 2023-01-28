class AddSiteIdToSkeletons < ActiveRecord::Migration[7.0]
  def change
    change_table :skeletons do |t|
      t.references :site
    end
  end
end
