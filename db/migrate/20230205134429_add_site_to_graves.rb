class AddSiteToGraves < ActiveRecord::Migration[7.0]
  def change
    add_reference :figures, :site
  end
end
