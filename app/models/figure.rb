# == Schema Information
#
# Table name: figures
#
#  id                  :bigint           not null, primary key
#  page_id             :bigint           not null
#  x1                  :integer          not null
#  x2                  :integer          not null
#  y1                  :integer          not null
#  y2                  :integer          not null
#  type                :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  area                :float
#  perimeter           :float
#  meter_ratio         :float
#  angle               :float
#  parent_id           :integer
#  identifier          :string
#  width               :float
#  height              :float
#  text                :string
#  site_id             :bigint
#  validated           :boolean          default(FALSE), not null
#  verified            :boolean          default(FALSE), not null
#  disturbed           :boolean          default(FALSE), not null
#  contour             :text             default([]), not null
#  deposition_type     :integer          default(0), not null
#  publication_id      :integer
#  percentage_scale    :integer
#  page_size           :integer
#  manual_bounding_box :boolean          default(FALSE)
#  bounding_box_angle  :integer
#  bounding_box_height :float
#  bounding_box_width  :float
#  control_point_1_x   :integer
#  control_point_1_y   :integer
#  control_point_2_x   :integer
#  control_point_2_y   :integer
#  control_point_3_x   :integer
#  control_point_3_y   :integer
#  control_point_4_x   :integer
#  control_point_4_y   :integer
#  anchor_point_1_x    :integer
#  anchor_point_1_y    :integer
#  anchor_point_2_x    :integer
#  anchor_point_2_y    :integer
#  anchor_point_3_x    :integer
#  anchor_point_3_y    :integer
#  anchor_point_4_x    :integer
#  anchor_point_4_y    :integer
#  probability         :float
#  contour_info        :jsonb
#
def bezier_point(anchor1:, anchor2:, control:, t:)
  return 0 if anchor2.nil? || anchor1.nil?
  ((1 - t) * (1 - t) * anchor1 + 2 * (1 - t) * t * control + t * t * anchor2).to_i
end

class Figure < ApplicationRecord
  belongs_to :page, dependent: :destroy
  belongs_to :publication, dependent: :destroy
  include UnitAccessor
  serialize :contour, JSON
  validates :publication, presence: true

  before_save do
    self.publication_id = page.publication_id
  end

  def manual_contour
    first = (0..1).step(0.1).map do |t|
      x = bezier_point(
        t: t,
        anchor1: anchor_point_1_x,
        anchor2: anchor_point_2_x,
        control: control_point_2_x
      )

      y = bezier_point(
        t: t,
        anchor1: anchor_point_1_y,
        anchor2: anchor_point_2_y,
        control: control_point_2_y
      )

      [x, y]
    end

    second = (0..1).step(0.1).map do |t|
      x = bezier_point(
        t: t,
        anchor1: anchor_point_2_x,
        anchor2: anchor_point_3_x,
        control: control_point_3_x
      )

      y = bezier_point(
        t: t,
        anchor1: anchor_point_2_y,
        anchor2: anchor_point_3_y,
        control: control_point_3_y
      )

      [x, y]
    end

    third = (0..1).step(0.1).map do |t|
      x = bezier_point(
        t: t,
        anchor1: anchor_point_3_x,
        anchor2: anchor_point_4_x,
        control: control_point_4_x
      )

      y = bezier_point(
        t: t,
        anchor1: anchor_point_3_y,
        anchor2: anchor_point_4_y,
        control: control_point_4_y
      )

      [x, y]
    end

    forth = (0..1).step(0.1).map do |t|
      x = bezier_point(
        t: t,
        anchor1: anchor_point_4_x,
        anchor2: anchor_point_1_x,
        control: control_point_1_x
      )

      y = bezier_point(
        t: t,
        anchor1: anchor_point_4_y,
        anchor2: anchor_point_1_y,
        control: control_point_1_y
      )
      [x, y]
    end

    first + second + third + forth
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
    x1 < figure.x1 + figure.box_width &&
      x1 + box_width > figure.x1 &&
      y1 < figure.y1 + figure.box_height &&
      y1 + box_height > figure.y1
  end

  def distance_to(figure)
    Distance.point_distance(
      {x: center.x, y: center.y},
      {x: figure.center.x, y: figure.center.y}
    )
  end

  # x_width, y_width is in meters
  def size_normalized_contour(x_width: 0.2, y_width: 0.2)
    return [] if contour.empty?

    single_contour = if is_a?(StoneTool)
      contour.max_by do |contour|
        if contour.size < 10
          0
        else
          ImageProcessing.contourArea(contour)
        end
      end
    else
      contour
    end

    return [] if single_contour.nil? || single_contour.size < 5

    bounding = ImageProcessing.boundingRect(single_contour)

    center_x = (bounding[:width] / 2) + bounding[:x]
    center_y = (bounding[:height] / 2) + bounding[:y]

    rotated_contour =
      if respond_to?(:arrow) && arrow.present?
        single_contour.map do |x, y|
          angle = (arrow.angle * Math::PI) / 180

          radians = angle * Math::PI / 180
          x2 = x - center_x
          y2 = y - center_y
          cos = Math.cos(radians)
          sin = Math.sin(radians)
          [(x2 * cos) - (y2 * sin) + center_x, (x2 * sin) + (y2 * cos) + center_y]
        end
      else
        single_contour
      end
    rotated_contour += [rotated_contour[0]]

    ratio = if scale&.meter_ratio.present?
      scale.meter_ratio
    elsif percentage_scale.present?
      cm_on_page = page_size.to_f / page.image.width
      (cm_on_page / 100.0) * percentage_scale
    else
      raise
    end

    center_x *= ratio
    center_y *= ratio

    offset_x = center_x - x_width
    offset_y = center_y - y_width

    rotated_contour.map do |x, y|
      [((x * ratio) - offset_x) * 1000, ((y * ratio) - offset_y) * 1000]
    end
  end
end
