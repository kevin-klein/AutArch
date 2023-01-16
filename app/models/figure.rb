# == Schema Information
#
# Table name: figures
#
#  id         :bigint           not null, primary key
#  page_id    :bigint           not null
#  x1         :integer          not null
#  x2         :integer          not null
#  y1         :integer          not null
#  y2         :integer          not null
#  type_name  :string           not null
#  tags       :string           not null, is an Array
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Figure < ApplicationRecord
  belongs_to :page
  has_many :skeletons, dependent: :destroy
  has_many :graves, class_name: 'Grave'
  has_many :grave_cross_sections, dependent: :destroy
  has_many :skulls, dependent: :destroy
  has_one :spine, dependent: :destroy
  has_one :arrow

  def width
    x2 - x1
  end

  def height
    y2 - y1
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
      x1 < figure.x1 + figure.width &&
      x1 + width > figure.x1 &&
      y1 < figure.y1 + figure.height &&
      y1 + height > figure.y1
    )
  end

  def distance_to(figure)
    center1 = center
    center2 = figure.center

    item1 = (center1[:x] - center2[:x]) ** 2
    item2 = (center1[:y] - center2[:y]) ** 2

    Math.sqrt(item1 + item2)
  end
end
