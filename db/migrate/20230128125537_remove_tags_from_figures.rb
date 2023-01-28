class RemoveTagsFromFigures < ActiveRecord::Migration[7.0]
  def change
    remove_column :figures, :tags
  end
end
