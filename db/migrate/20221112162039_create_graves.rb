class CreateGraves < ActiveRecord::Migration[7.0]
  def change
    create_table :sites do |t|
      t.float :lat
      t.float :lon
      t.string :name
    end

    create_table :graves do |t|
      t.string :location
      t.references :figure, null: false, foreign_key: true
      t.references :site, null: false, foreign_key: false

      t.timestamps
    end
  end
end
