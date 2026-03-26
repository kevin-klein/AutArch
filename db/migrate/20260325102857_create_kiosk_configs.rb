class CreateKioskConfigs < ActiveRecord::Migration[8.1]
  def change
    create_table :kiosk_configs do |t|
      t.references :page, null: false, foreign_key: true
      t.references :figure, null: false, foreign_key: true

      t.timestamps
    end
  end
end
