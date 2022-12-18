class CreateCrossSectionArrows < ActiveRecord::Migration[7.0]
  def change
    create_table :cross_section_arrows do |t|
      t.references :figure, null: false, foreign_key: true
      t.references :grave, null: false, foreign_key: true
      t.integer :length

      t.timestamps
    end
  end
end
