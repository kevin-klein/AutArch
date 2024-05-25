class FixFigureBelongsTo < ActiveRecord::Migration[7.0]
  def up
    change_column :graves, :figure_id, :integer, foreign_key: {on_delete: :cascade}
    change_column :arrows, :figure_id, :integer, foreign_key: {on_delete: :cascade}
    change_column :goods, :figure_id, :integer, foreign_key: {on_delete: :cascade}
    change_column :grave_cross_sections, :figure_id, :integer, foreign_key: {on_delete: :cascade}
    change_column :scales, :figure_id, :integer, foreign_key: {on_delete: :cascade}
    change_column :graves, :figure_id, :integer, foreign_key: {on_delete: :cascade}
    change_column :skeletons, :figure_id, :integer, foreign_key: {on_delete: :cascade}
    change_column :skulls, :figure_id, :integer, foreign_key: {on_delete: :cascade}
  end

  def down
  end
end
