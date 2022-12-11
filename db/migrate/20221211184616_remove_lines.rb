class RemoveLines < ActiveRecord::Migration[7.0]
  def change
    remove_reference :spines, :line, index: true, foreign_key: true
    add_reference :spines, :figure, index: true, foreign_key: true
    drop_table :lines
  end
end
