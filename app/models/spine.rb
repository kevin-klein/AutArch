# == Schema Information
#
# Table name: spines
#
#  id         :bigint           not null, primary key
#  grave_id   :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  figure_id  :bigint
#
class Spine < ApplicationRecord
  belongs_to :grave
  belongs_to :figure

  def angle
    y_axis = Vector[0, 1]
    figure_vector = Vector[(figure.x2 - figure.x1).abs, (figure.y1 - figure.y2).abs].normalize

    figure_vector.angle_with(y_axis) * 57.29578
  end
end
