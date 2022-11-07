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
require "test_helper"

class FigureTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
