# == Schema Information
#
# Table name: graves
#
#  id         :bigint           not null, primary key
#  location   :string
#  figure_id  :integer          not null
#  site_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  arc_length :float
#  area       :float
#  kurgan_id  :bigint
#
class Grave < ApplicationRecord
  belongs_to :figure
  delegate :page, to: :figure
  belongs_to :site, required: false
  has_one :scale, dependent: :destroy
  has_one :arrow, dependent: :destroy
  has_one :grave_cross_section, dependent: :destroy
  has_many :goods, dependent: :destroy
  has_many :spines, dependent: :destroy
  has_one :cross_section_arrow, dependent: :destroy
  has_many :skeletons, dependent: :destroy
  has_many :skulls, through: :skeletons
  has_many :spines, dependent: :destroy
  belongs_to :kurgan

  def upwards?
    figure.width < figure.height
  end

  def width_height
    return [] unless scale.present?

    if upwards?
      [figure.height / meter_pixel, figure.width / meter_pixel]
    else
      [figure.width / meter_pixel, figure.height / meter_pixel]
    end
  end

  def meter_pixel
    scale&.figure&.width
  end

  def area_with_unit
    if scale.present? && scale.meter_ratio > 0 && area > 0
      { value: area * scale.meter_ratio ** 2, unit: 'm' }
    else
      { value: area, unit: 'px' }
    end
  end

  def arc_length_with_unit
    if scale.present? && scale.meter_ratio > 0 && arc_length > 0
      { value: arc_length * scale.meter_ratio, unit: 'm' }
    else
      { value: arc_length, unit: 'px' }
    end
  end

  def figures
    ([
      figure,
      scale&.figure,
      arrow&.figure,
      grave_cross_section&.figure,
      cross_section_arrow&.figure
    ] + spines.map(&:figure) + skulls.map(&:figure) + skeletons.map(&:figure) + goods.map(&:figure) + spines.map(&:figure)).compact
  end

  def self.area_arc_stats
    Grave
      .select { _1.area_with_unit[:unit] == 'm' }
      .select { _1.area_with_unit[:value].round(1) > 0 }
      .group_by { _1.area_with_unit[:value].round(1) }
      .map { |k, v| [k, v.count] }
  end
end
