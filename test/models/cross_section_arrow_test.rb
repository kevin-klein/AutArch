# == Schema Information
#
# Table name: cross_section_arrows
#
#  id         :bigint           not null, primary key
#  figure_id  :bigint           not null
#  grave_id   :bigint           not null
#  length     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class CrossSectionArrowTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
