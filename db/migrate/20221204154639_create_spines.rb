class CreateSpines < ActiveRecord::Migration[7.0]
  def change
    create_table :spines do |t|
      t.references :line, null: false, foreign_key: true
      t.references :grave, null: false, foreign_key: true

      t.timestamps
    end
  end
end
