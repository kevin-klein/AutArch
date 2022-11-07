class CreatePageImages < ActiveRecord::Migration[7.0]
  def change
    create_table :page_images do |t|
      t.references :page, null: false, foreign_key: { on_delete: :cascade }
      t.references :image, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end

    create_table :figures do |t|
      t.references :page, null: false, foreign_key: { on_delete: :cascade }
      t.float :x1, null: false
      t.float :x2, null: false
      t.float :y1, null: false
      t.float :y2, null: false
      t.string :type, null: false
      t.string :tags, array: true, null: false

      t.timestamps
    end
  end
end
