class MakeC14DateFieldsOptional < ActiveRecord::Migration[7.0]
  def change
    change_table :c14_dates do |t|
      t.change :age_bp, :integer, null: true
      t.change :interval, :integer, null: true
    end
  end
end
