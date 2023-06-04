class CreateC14Dates < ActiveRecord::Migration[7.0]
  def change
    create_table :c14_dates do |t|
      t.integer :c14_type, null: false
      t.string :lab_id
      t.integer :age_bp, null: false
      t.integer :interval, null: false
      t.integer :material
      t.float :calbc_1sigma_max
      t.float :calbc_1_sigma_min
      t.float :calbc_2sigma_max
      t.float :calbc_2sigma_min
      t.string :date_note
      t.integer :cal_method
      t.string :ref_14c
      t.references :chronology, null: false

      t.timestamps
    end
  end
end
