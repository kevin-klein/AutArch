class CreateGraves < ActiveRecord::Migration[7.0]
  def change
    create_table :graves do |t|
      t.string :location
      t.references :figure, null: false, foreign_key: true

      t.timestamps
    end
  end
end
