# == Schema Information
#
# Table name: lines
#
#  id         :bigint           not null, primary key
#  x          :integer
#  y          :integer
#  page_id    :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class LineTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
