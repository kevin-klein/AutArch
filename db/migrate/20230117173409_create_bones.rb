class CreateBones < ActiveRecord::Migration[7.0]
  def change
    create_table :bones do |t|
      t.string :name

      t.timestamps
    end

    change_table :c14_dates do |t|
      t.references :bone
    end

    change_table :stable_isotopes do |t|
      t.references :bone
    end

    change_table :genetics do |t|
      t.references :bone
    end
  end
end
