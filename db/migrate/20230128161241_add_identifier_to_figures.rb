class AddIdentifierToFigures < ActiveRecord::Migration[7.0]
  def change
    change_table :figures do |t|
      t.string :identifier
      t.float :width
      t.float :height
    end
  end
end
