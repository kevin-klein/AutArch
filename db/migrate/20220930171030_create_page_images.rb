class CreatePageImages < ActiveRecord::Migration[7.0]
  def change
    create_table :page_images do |t|
      t.references :page, null: false, foreign_key: { on_delete: :cascade }
      t.references :image, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end

    create_table :figures do |t|
      t.references :page_image, null: false, foreign_key: { on_delete: :cascade }
      t.jsonb :shape, null: false
      t.string :tags, array: true

      t.timestamps
    end
  end
end
