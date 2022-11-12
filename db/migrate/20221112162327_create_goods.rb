class CreateGoods < ActiveRecord::Migration[7.0]
  def change
    create_table :goods do |t|
      t.references :grave, null: false, foreign_key: true
      t.references :figure, null: false, foreign_key: true
      t.integer :type

      t.timestamps
    end
  end
end
