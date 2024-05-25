class ChangePoints < ActiveRecord::Migration[7.0]
  def change
    add_column :figures, :contour, :text, default: "[]", null: false
  end
end
