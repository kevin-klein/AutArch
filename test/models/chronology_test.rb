# == Schema Information
#
# Table name: chronologies
#
#  id           :bigint           not null, primary key
#  context_from :integer
#  context_to   :integer
#  skeleton_id  :bigint
#  grave_id     :bigint
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  period_id    :bigint
#
require "test_helper"

class ChronologyTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
