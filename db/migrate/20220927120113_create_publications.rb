class CreatePublications < ActiveRecord::Migration[7.0]
  def change
    create_table :publications do |t|
      t.binary :pdf
      t.string :author
      t.string :title

      t.timestamps
    end
  end
end
