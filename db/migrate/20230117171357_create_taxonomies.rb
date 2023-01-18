class CreateTaxonomies < ActiveRecord::Migration[7.0]
  def change
    create_table :taxonomies do |t|
      t.references :skeleton
      t.string :culture_note
      t.string :culture_reference

      t.timestamps
    end
  end
end
