class CreateLines < ActiveRecord::Migration[7.0]
  def change
    create_table :lines do |t|
      t.integer :x
      t.integer :y
      t.references :page, null: false, foreign_key: true

      t.timestamps
    end
  end
end
