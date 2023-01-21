class RemovePathologiesFromAnthropology < ActiveRecord::Migration[7.0]
  def change
    remove_column :anthropologies, :pathologies
  end
end
