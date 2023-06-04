class AddPublicationIdToFigures < ActiveRecord::Migration[7.0]
  def change
    add_column :figures, :publication_id, :string
  end
end
