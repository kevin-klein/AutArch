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
#
class Grave < ApplicationRecord
  belongs_to :figure
  belongs_to :site, required: false
  has_one :scale
  has_one :arrow
  has_many :graves
  has_one :grave_cross_section
  has_many :goods
  has_many :spines
  has_one :cross_section_arrow
  has_many :skeletons

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

  def figures
    ([
      figure,
      scale&.figure,
      arrow&.figure,
      grave_cross_section&.figure,
      cross_section_arrow&.figure
    ] + skeletons.map(&:figure) + goods.map(&:figure) + spines.map(&:figure)).compact
  end
end
