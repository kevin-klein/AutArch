class DropSharePublications < ActiveRecord::Migration[8.1]
  def change
    drop_table :share_publications
  end
end
