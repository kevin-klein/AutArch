class CreateArchaeology < ActiveRecord::Migration[7.0]
  def change
    change_table :skeletons do |t|
      t.integer :funerary_practice
      t.integer :inhumation_type
      t.integer :anatonimcal_connection
      t.integer :body_position
      t.integer :crouching_type
      t.string :other
      t.float :head_facing
      t.integer :ochre
      t.integer :ochre_position
    end

    change_table :anthropologies do |t|
      t.integer :species
    end

    change_table :graves do |t|
      t.remove :location
    end
  end
end
