class CreateSkulls < ActiveRecord::Migration[7.0]
  def change
    create_table :skulls do |t|
      t.references :skeleton, null: false, foreign_key: true
      t.references :figure, null: false, foreign_key: true

      t.timestamps
    end
  end
end
