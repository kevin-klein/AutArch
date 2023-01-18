class CreateAnthropologies < ActiveRecord::Migration[7.0]
  def change
    create_table :anthropologies do |t|
      t.integer :sex_morph
      t.integer :sex_gen
      t.integer :sex_consensus
      t.string :age_as_reported
      t.integer :age_class
      t.float :height
      t.integer :pathologies
      t.string :pathologies_type
      t.references :skeleton

      t.timestamps
    end
  end
end
