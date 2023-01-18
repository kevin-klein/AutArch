class CreateKurgans < ActiveRecord::Migration[7.0]
  def change
    create_table :kurgans do |t|
      t.integer :width
      t.integer :height
      t.string :name, null: false
      t.references :publication

      t.timestamps
    end

    change_table :graves do |t|
      t.references :kurgan
    end
  end
end
