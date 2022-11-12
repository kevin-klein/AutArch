# == Schema Information
#
# Table name: figures
#
#  id         :bigint           not null, primary key
#  page_id    :bigint           not null
#  x1         :float            not null
#  x2         :float            not null
#  y1         :float            not null
#  y2         :float            not null
#  type       :string           not null
#  tags       :string           not null, is an Array
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Figure < ApplicationRecord
  belongs_to :page

  def width
    x2 - x1
  end

  def height
    y2 - y1
  end
end
