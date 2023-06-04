class AddDepositionTypeToSkeleton < ActiveRecord::Migration[7.0]
  def change
    add_column :figures, :deposition_type, :integer, null: false, default: 0
  end
end
