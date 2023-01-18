class CreateYHaplogroups < ActiveRecord::Migration[7.0]
  def change
    create_table :y_haplogroups do |t|
      t.string :name

      t.timestamps
    end

    change_table :genetics do |t|
      t.references :y_haplogroup
    end
  end
end
