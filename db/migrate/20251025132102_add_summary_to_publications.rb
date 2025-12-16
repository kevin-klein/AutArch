class AddSummaryToPublications < ActiveRecord::Migration[7.0]
  def change
    add_column :publications, :summary, :text
  end
end
