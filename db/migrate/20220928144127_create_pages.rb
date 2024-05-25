class CreatePages < ActiveRecord::Migration[7.0]
  def change
    create_table :pages do |t|
      t.references :publication, null: false, foreign_key: {on_delete: :cascade}
      t.integer :number
      t.references :image, null: false, foreign_key: {on_delete: :cascade}

      t.timestamps
    end
  end
end
