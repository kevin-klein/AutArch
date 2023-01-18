class CreateMtHaplogroups < ActiveRecord::Migration[7.0]
  def change
    create_table :mt_haplogroups do |t|
      t.string :name

      t.timestamps
    end

    change_table :genetics do |t|
      t.references :mt_haplogroup
    end
  end
end
