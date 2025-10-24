class CreateObjectSimilarities < ActiveRecord::Migration[7.0]
  def change
    create_table :object_similarities do |t|
      t.string :type
      t.float :similarity
      t.references :first, null: false, foreign_key: {to_table: :figures}
      t.references :second, null: false, foreign_key: {to_table: :figures}

      t.timestamps
    end
  end
end
