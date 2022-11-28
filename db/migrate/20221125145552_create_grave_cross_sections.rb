class CreateGraveCrossSections < ActiveRecord::Migration[7.0]
  def change
    create_table :grave_cross_sections do |t|
      t.references :grave, null: false, foreign_key: true
      t.references :figure, null: false, foreign_key: true

      t.timestamps
    end
  end
end
