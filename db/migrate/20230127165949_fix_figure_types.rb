class FixFigureTypes < ActiveRecord::Migration[7.0]
  class Figure < ApplicationRecord
    self.inheritance_column = "type_id"
  end

  def up
    Figure.find_each do |figure|
      figure.type = figure.type.camelize.singularize
      figure.save!
    end
  end

  def down
    Figure.find_each do |figure|
      figure.type = figure.type.camelize.singularize
      figure.save!
    end
  end
end
