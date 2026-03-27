class DropAnalysisWizards < ActiveRecord::Migration[8.1]
  def change
    remove_column :figures, :wizard_id, :bigint

    drop_table :analysis_wizards
  end
end
