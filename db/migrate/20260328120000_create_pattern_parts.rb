class CreatePatternParts < ActiveRecord::Migration[7.0]
  def change
    create_table :pattern_parts do |t|
      t.references :figure, null: false, foreign_key: true
      t.integer :x1, null: false
      t.integer :y1, null: false
      t.integer :x2, null: false
      t.integer :y2, null: false
      t.text :description
      t.float :confidence, default: 1.0
      t.integer :feature_type, default: 0 # 0: texture, 1: color, 2: edge
      t.jsonb :features, default: {}

      t.timestamps
    end

    add_index :pattern_parts, [:x1, :y1, :x2, :y2]
  end
end
