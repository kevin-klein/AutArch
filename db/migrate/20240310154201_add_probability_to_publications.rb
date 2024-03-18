class AddProbabilityToPublications < ActiveRecord::Migration[7.0]
  def change
    add_column :figures, :probability, :float
  end
end
