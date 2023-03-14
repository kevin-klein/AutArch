class CreateShapePoints < ActiveRecord::Migration[7.0]
  def change
    create_table :shape_points do |t|
      t.references :figure, null: false, foreign_key: true
      t.integer :x
      t.integer :y

      t.timestamps
    end
  end
end
