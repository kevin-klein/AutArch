# == Schema Information
#
# Table name: figures
#
#  id                    :integer          not null, primary key
#  page_id               :integer          not null
#  x1                    :integer          not null
#  x2                    :integer          not null
#  y1                    :integer          not null
#  y2                    :integer          not null
#  type                  :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  area                  :float
#  perimeter             :float
#  meter_ratio           :float
#  angle                 :float
#  parent_id             :integer
#  identifier            :string
#  width                 :float
#  height                :float
#  text                  :string
#  site_id               :integer
#  validated             :boolean          default(FALSE), not null
#  verified              :boolean          default(FALSE), not null
#  disturbed             :boolean          default(FALSE), not null
#  contour               :text             default([]), not null
#  deposition_type       :integer          default(0), not null
#  publication_id        :string
#  percentage_scale      :integer
#  page_size             :integer
#  manual_bounding_box   :boolean          default(FALSE)
#  bounding_box_center_x :integer
#  bounding_box_center_y :integer
#  bounding_box_angle    :integer
#  bounding_box_width    :integer
#  bounding_box_height   :integer
#
# typed: strict
## == Schema Information
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
#  site_id     :bigint
#
class Figure < ApplicationRecord
  belongs_to :page
  belongs_to :publication
  include UnitAccessor
  serialize :contour, JSON
  validates_presence_of :publication

  before_save do
    self.publication_id = page.publication_id
  end

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
    Point.new(
      x: (x1 + x2) / 2,
      y: (y1 + y2) / 2
    )
  end

  def contains?(figure)
    figure.x1.between?(x1, x2) &&
      figure.x2.between?(x1, x2) &&
      figure.y1.between?(y1, y2) &&
      figure.y2.between?(y1, y2)
  end

  def collides?(figure) # rubocop:disable Metrics/AbcSize
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

    item1 = (center1.x - center2.x)**2
    item2 = (center1.y - center2.y)**2

    Math.sqrt(item1 + item2)
  end

  def size_normalized_contour
    return [] if contour.length == 0
    bounding = ImageProcessing.boundingRect(contour)
    x_scale = 800.0 / bounding[:height]
    y_scale = 800.0 / bounding[:width]
    scale = [x_scale, y_scale].min
    contour.map do |x, y|
      x = x - bounding[:x]
      y = y - bounding[:y]
      raise if x * scale > 1000
      [x * scale, y * scale]
    end
  end
end
