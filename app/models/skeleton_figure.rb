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
class SkeletonFigure < Figure
  belongs_to :grave, foreign_key: 'parent_id', optional: true

  has_many :skulls, foreign_key: 'parent_id', class_name: 'Skull'
end
