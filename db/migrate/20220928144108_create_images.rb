class CreateImages < ActiveRecord::Migration[7.0]
  def change
    create_table :images do |t|
      t.binary :data

      t.timestamps
    end
  end
end
