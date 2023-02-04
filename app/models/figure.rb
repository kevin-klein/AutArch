# == Schema Information
#
# Table name: figures
#
#  id          :bigint           not null, primary key
#  page_id     :bigint           not null
#  x1          :integer          not null
#  x2          :integer          not null
#  y1          :integer          not null
#  y2          :integer          not null
#  type        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  area        :float
#  perimeter   :float
#  meter_ratio :float
#  angle       :float
#  parent_id   :integer
#  identifier  :string
#  width       :float
#  height      :float
#  text        :string
#
class Figure < ApplicationRecord
  belongs_to :page
  include UnitAccessor

  def box_width
    x2 - x1
  end

  def box_height
    y2 - y1
  end

  def vector
    Vector[box_width, box_height]
  end

  def center
    {
      x: (x1 + x2) / 2,
      y: (y1 + y2) / 2
    }
  end

  def contains?(figure)
    figure.x1.between?(x1, x2) &&
      figure.x2.between?(x1, x2) &&
      figure.y1.between?(y1, y2) &&
      figure.y2.between?(y1, y2)
  end

  def collides?(figure)
    (
      x1 < figure.x1 + figure.box_width &&
      x1 + box_width > figure.x1 &&
      y1 < figure.y1 + figure.box_height &&
      y1 + box_height > figure.y1
    )
  end

  def distance_to(figure)
    center1 = center
    center2 = figure.center

    item1 = (center1[:x] - center2[:x])**2
    item2 = (center1[:y] - center2[:y])**2

    Math.sqrt(item1 + item2)
  end
end
