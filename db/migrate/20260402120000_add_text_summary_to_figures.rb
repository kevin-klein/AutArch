class AddTextSummaryToFigures < ActiveRecord::Migration[8.1]
  def change
    add_column :figures, :text_summary, :text
  end
end