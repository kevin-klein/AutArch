# == Schema Information
#
# Table name: spines
#
#  id          :bigint           not null, primary key
#  grave_id    :bigint           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  figure_id   :bigint
#  skeleton_id :bigint
#
require "test_helper"

class SpineTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
