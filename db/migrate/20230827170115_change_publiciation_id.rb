class ChangePubliciationId < ActiveRecord::Migration[7.0]
  def change
    change_column :figures, :publication_id, "integer USING publication_id::integer"
  end
end
