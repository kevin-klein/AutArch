class CreateSharePublications < ActiveRecord::Migration[8.1]
  def change
    create_table :share_publications do |t|
      t.references :publication, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
