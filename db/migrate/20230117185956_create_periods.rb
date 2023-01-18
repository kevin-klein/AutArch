class CreatePeriods < ActiveRecord::Migration[7.0]
  def change
    create_table :periods do |t|
      t.string :name

      t.timestamps
    end

    change_table :chronologies do |t|
      t.remove :period

      t.references :period
    end
  end
end
