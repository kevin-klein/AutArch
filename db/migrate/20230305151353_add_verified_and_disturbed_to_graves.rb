class AddVerifiedAndDisturbedToGraves < ActiveRecord::Migration[7.0]
  def change
    add_column :figures, :verified, :boolean, default: false, null: false, bulk: true
    add_column :figures, :disturbed, :boolean, default: false, null: false, bulk: true
  end
end
