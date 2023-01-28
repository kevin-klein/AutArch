class ChangeFiguresToSti < ActiveRecord::Migration[7.0]
  def change
    change_table :figures do |t|
      t.rename :type_name, :type
      t.float :area
      t.float :perimeter
      t.float :meter_ratio
      t.float :angle
      t.integer :parent_id
    end

    change_table :skeletons do |t|
      t.remove :grave_id
    end

    drop_table :skulls
    drop_table :skeleton_figures
    drop_table :goods
    drop_table :grave_cross_sections
    drop_table :cross_section_arrows
    drop_table :scales
    drop_table :arrows
    drop_table :spines
    drop_table :graves
  end
end
