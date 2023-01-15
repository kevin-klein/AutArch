class AddSizeToImage < ActiveRecord::Migration[7.0]
  def change
    change_table :images do |t|
      t.integer :width
      t.integer :height
    end
  end
end
