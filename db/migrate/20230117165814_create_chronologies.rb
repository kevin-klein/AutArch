class CreateChronologies < ActiveRecord::Migration[7.0]
  def change
    create_table :chronologies do |t|
      t.integer :period
      t.integer :context_from
      t.integer :context_to
      t.references :skeleton
      t.references :grave

      t.timestamps
    end
  end
end
