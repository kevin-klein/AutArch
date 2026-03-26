class CreateAnalysisWizards < ActiveRecord::Migration[7.0]
  def change
    create_table :analysis_wizards do |t|
      t.integer :step, default: 0
      t.references :page, null: true, foreign_key: {to_table: :pages}
      t.jsonb :contours, default: [], array: true
      t.text :state

      t.timestamps
    end
    #add_index :analysis_wizards, :step
    #add_index :analysis_wizards, :page_id
  end
end
