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
  belongs_to :site, required: false
  has_one :scale, dependent: :destroy, foreign_key: 'parent_id', class_name: 'Scale'
  has_one :arrow, dependent: :destroy, foreign_key: 'parent_id', class_name: 'Arrow'
  has_one :grave_cross_section, dependent: :destroy, foreign_key: 'parent_id', class_name: 'GraveCrossSection'
  has_many :goods, dependent: :destroy, foreign_key: 'parent_id', class_name: 'Good'
  has_many :spines, dependent: :destroy, foreign_key: 'parent_id', class_name: 'Spine'
  has_one :cross_section_arrow, dependent: :destroy, foreign_key: 'parent_id', class_name: 'CrossSectionArrow'
  has_many :skeleton_figures, dependent: :destroy, foreign_key: 'parent_id', class_name: 'SkeletonFigure'
  has_many :skulls, through: :skeleton_figures, foreign_key: 'parent_id', class_name: 'Skull'
  has_many :spines, dependent: :destroy, foreign_key: 'parent_id', class_name: 'Spine'

  def upwards?
    width < height
  end

  def width_height
    return [] unless scale.present?

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
      .filter { _1.area_with_unit[:value].round(1) > 0 }
      .group_by { _1.area_with_unit[:value].round(1) }
      .map { |k, v| [k, v.count] }
  end
end
