class CreatePageTexts < ActiveRecord::Migration[7.0]
  def change
    create_table :page_texts do |t|
      t.references :page, null: false, foreign_key: true
      t.string :text

      t.timestamps
    end
  end
end
