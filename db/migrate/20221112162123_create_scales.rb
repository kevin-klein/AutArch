class CreateScales < ActiveRecord::Migration[7.0]
  def change
    create_table :scales do |t|
      t.references :figure, null: false, foreign_key: true
      t.references :grave, null: false, foreign_key: true
      t.float :meter_ratio

      t.timestamps
    end
  end
end
