class AddRealWorldUnitsToFigures < ActiveRecord::Migration[7.0]
  def change
    change_table :figures do |t|
      t.float :real_world_area
      t.float :real_world_width
      t.float :real_world_height
      t.float :real_world_perimeter
    end

    Grave.find_each do |figure|
      attrs = [:area, :width, :height, :perimeter]

      attrs.each do |attr|
        value = figure.send(:"#{attr}_with_unit")
        if value[:unit] != "px"
          figure.send(:"real_world_#{attr}=", value[:value])
        end
      end

      figure.save!
    end
  end
end
