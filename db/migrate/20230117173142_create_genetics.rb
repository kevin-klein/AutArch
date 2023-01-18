class CreateGenetics < ActiveRecord::Migration[7.0]
  def change
    create_table :genetics do |t|
      t.integer :data_type
      t.float :end_content
      t.string :ref_gen
      t.references :skeleton, null: false, foreign_key: true

      t.timestamps
    end
  end
end
