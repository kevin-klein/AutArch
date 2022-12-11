# == Schema Information
#
# Table name: arrows
#
#  id         :bigint           not null, primary key
#  grave_id   :bigint           not null
#  figure_id  :integer          not null
#  angle      :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class ArrowTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
