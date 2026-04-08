class AddTextToPublications < ActiveRecord::Migration[8.1]
  def change
    add_column :publications, :text, :text
  end
end
