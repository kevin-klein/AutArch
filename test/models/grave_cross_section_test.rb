# == Schema Information
#
# Table name: grave_cross_sections
#
#  id         :bigint           not null, primary key
#  grave_id   :bigint           not null
#  figure_id  :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class GraveCrossSectionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
