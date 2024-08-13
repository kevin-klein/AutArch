class AddTagsToGraves < ActiveRecord::Migration[7.0]
  def change
    create_table :tags do |t|
      t.string :name, null: false
    end

    create_table :figures_tags do |t|
      t.references :tag
      t.references :figure
    end
  end
end
