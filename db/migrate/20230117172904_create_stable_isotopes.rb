class CreateStableIsotopes < ActiveRecord::Migration[7.0]
  def change
    create_table :stable_isotopes do |t|
      t.references :skeleton, null: false, foreign_key: true
      t.string :iso_id
      t.float :iso_value
      t.string :ref_iso
      t.integer :isotope
      t.integer :baseline

      t.timestamps
    end
  end
end
