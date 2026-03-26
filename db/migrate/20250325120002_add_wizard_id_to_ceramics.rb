class AddWizardIdToCeramics < ActiveRecord::Migration[7.0]
  def change
    add_column :figures, :wizard_id, :bigint
    add_foreign_key :figures, :analysis_wizards, column: :wizard_id
    add_index :figures, :wizard_id
  end
end
