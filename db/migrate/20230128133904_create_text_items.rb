class CreateTextItems < ActiveRecord::Migration[7.0]
  def change
    create_table :text_items do |t|
      t.references :page, null: false, foreign_key: true
      t.string :text
      t.integer :x1
      t.integer :x2
      t.integer :y1
      t.integer :y2

      t.timestamps
    end
  end
end
