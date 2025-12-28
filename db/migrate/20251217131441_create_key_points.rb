class CreateKeyPoints < ActiveRecord::Migration[8.1]
  def change
    create_table :key_points do |t|
      t.integer :label, null: false
      t.integer :x, null: false
      t.integer :y, null: false
      t.references :figure, null: false, foreign_key: true

      t.timestamps
    end
  end
end
