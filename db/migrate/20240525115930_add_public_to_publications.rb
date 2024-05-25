class AddPublicToPublications < ActiveRecord::Migration[7.0]
  def change
    add_column :publications, :public, :boolean, default: false, null: false
  end
end
