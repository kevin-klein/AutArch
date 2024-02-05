class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :code_hash
      t.string :name
      t.integer :role

      t.timestamps
    end
  end
end
