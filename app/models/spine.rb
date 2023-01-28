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
#  tags        :string           not null, is an Array
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  area        :float
#  perimeter   :float
#  meter_ratio :float
#  angle       :float
#  parent_id   :integer
#
class Spine < Figure
  belongs_to :skeleton_figure, foreign_key: 'parent_id', optional: true

  def angle
    y_axis = Vector[0, 1]
    figure_vector = Vector[(x2 - x1).abs, (y1 - y2).abs].normalize

    figure_vector.angle_with(y_axis) * 57.29578
  end
end
