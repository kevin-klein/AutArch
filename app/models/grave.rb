class Grave < ApplicationRecord
  belongs_to :figure
  belongs_to :site
  has_one :scale
  has_one :arrow
  has_many :graves
  has_many :goods
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

    ] + skeletons.map(&:figure) + goods.map(&:figure)).compact
  end
end
