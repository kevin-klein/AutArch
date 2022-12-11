# == Schema Information
#
# Table name: scales
#
#  id          :bigint           not null, primary key
#  figure_id   :integer          not null
#  grave_id    :bigint           not null
#  meter_ratio :float
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require "test_helper"

class ScaleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
