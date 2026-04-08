class AddFigureText < ActiveRecord::Migration[7.0]
  def change
    create_table :figure_texts do |t|
      t.references :figure, null: false, foreign_key: true
      t.string :ocr_text
      t.json :extracted_dimensions
      t.string :extracted_description
      t.string :extracted_summary
      t.json :key_phrases
      t.string :raw_text

      t.timestamps
    end
  end
end
