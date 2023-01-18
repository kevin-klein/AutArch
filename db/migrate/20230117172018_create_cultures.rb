class CreateCultures < ActiveRecord::Migration[7.0]
  def change
    create_table :cultures do |t|
      t.string :name

      t.timestamps
    end

    change_table :taxonomies do |t|
      t.references :culture
    end
  end
end
