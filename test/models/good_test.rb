# == Schema Information
#
# Table name: goods
#
#  id         :bigint           not null, primary key
#  grave_id   :bigint           not null
#  figure_id  :integer          not null
#  type       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class GoodTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
