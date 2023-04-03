class AddValidatedToGraves < ActiveRecord::Migration[7.0]
  def change
    add_column :figures, :validated, :boolean, default: false, null: false
  end
end
