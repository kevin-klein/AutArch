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
class Grave < Figure
  belongs_to :site, optional: true
  has_one :scale, dependent: :destroy, foreign_key: 'parent_id', class_name: 'Scale', inverse_of: :grave
  has_one :arrow, dependent: :destroy, foreign_key: 'parent_id', class_name: 'Arrow', inverse_of: :grave
  has_one :grave_cross_section, dependent: :destroy, foreign_key: 'parent_id', class_name: 'GraveCrossSection',
                                inverse_of: :grave
  has_many :goods, dependent: :destroy, foreign_key: 'parent_id', class_name: 'Good', inverse_of: :grave
  has_many :spines, dependent: :destroy, foreign_key: 'parent_id', class_name: 'Spine', inverse_of: :grave
  has_one :cross_section_arrow, dependent: :destroy, foreign_key: 'parent_id', class_name: 'CrossSectionArrow',
                                inverse_of: :grave
  has_many :skeleton_figures, dependent: :destroy, foreign_key: 'parent_id', class_name: 'SkeletonFigure',
                              inverse_of: :grave
  has_many :skulls, through: :skeleton_figures, foreign_key: 'parent_id', class_name: 'Skull', inverse_of: :grave
  has_many :spines, dependent: :destroy, foreign_key: 'parent_id', class_name: 'Spine', inverse_of: :grave

  accepts_nested_attributes_for :skeleton_figures
  validates :identifier, uniqueness: { scope: :publication }, allow_blank: true

  def upwards?
    width < height
  end

  def spine_orientations # rubocop:disable Metrics/AbcSize
    spines.map do |spine|
      angle = (arrow.angle * Math::PI) / 180
      rotation_matrix = Matrix[[Math.cos(angle), Math.sin(angle)], [-Math.sin(angle), Math.cos(angle)]]
      spine_matrix1 = Matrix[[1, 0]]
      x1_points = spine_matrix1 * rotation_matrix
      x1_points = x1_points.row(0)
      angle = Math.atan2(spine.vector[1], spine.vector[0]) - Math.atan2(x1_points[1], x1_points[0])
      angle += Math::PI
      angle * 180 / Math::PI
    end
  end

  def width_height
    return [] if scale.blank?

    if upwards?
      [height / meter_pixel, width / meter_pixel]
    else
      [width / meter_pixel, height / meter_pixel]
    end
  end

  def meter_pixel
    scale&.width
  end

  with_unit :area, square: true
  with_unit :perimeter
  with_unit :width
  with_unit :height
  with_unit :bounding_box_width
  with_unit :bounding_box_height

  with_unit :normalized_width
  with_unit :normalized_height

  def normalized_width
    if bounding_box_width.present?
      bounding_box_width
    else
      width
    end
  end

  def normalized_height
    if bounding_box_height.present?
      bounding_box_height
    else
      height
    end
  end

  def figures
    ([
      self,
      scale,
      arrow,
      grave_cross_section,
      cross_section_arrow
    ] + spines + skulls + skeleton_figures + goods + spines).compact.uniq
  end

  def self.area_arc_stats
    Grave
      .all
      .filter { _1.area_with_unit[:unit] == 'm' }
      .filter { _1.area_with_unit[:value].round(1).positive? }
      .group_by { _1.area_with_unit[:value].round(1) }
      .map { |k, v| [k, v.count] }
  end
end
