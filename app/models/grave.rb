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

      ## angle = (arrow.angle * Math::PI) / 180

      # spine_matrix1 = Matrix[[spine.x1, spine.y1]]
      # spine_matrix2 = Matrix[[spine.x2, spine.y2]]
      # rotation_matrix = Matrix[[Math.cos(angle), Math.sin(angle)], [-Math.sin(angle), Math.cos(angle)]]

      # x1_points = spine_matrix1 * rotation_matrix
      # x2_points = spine_matrix2 * rotation_matrix

      # ap x1_points

      # figure_vector = x2_points - x1_points
      # ap figure_vector
      # figure_vector = figure_vector.row(0)
      # y_axis = Vector[[1, 0]]

      # Math.atan2(v2.y, v2.x) - atan2(v1.y, v1.x)
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
