class CreatePageImages < ActiveRecord::Migration[7.0]
  def change
    create_table :figures do |t|
      t.references :page, null: false, foreign_key: {on_delete: :cascade}
      t.integer :x1, null: false
      t.integer :x2, null: false
      t.integer :y1, null: false
      t.integer :y2, null: false
      t.string :type_name, null: false
      t.string :tags, array: true, null: false

      t.timestamps
    end
  end
end
