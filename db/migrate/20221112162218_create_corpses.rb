class CreateCorpses < ActiveRecord::Migration[7.0]
  def change
    create_table :corpses do |t|
      t.references :grave, null: false, foreign_key: true
      t.references :figure, null: false, foreign_key: true
      t.float :angle

      t.timestamps
    end
  end
end
