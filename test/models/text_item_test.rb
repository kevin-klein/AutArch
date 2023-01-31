# == Schema Information
#
# Table name: text_items
#
#  id         :bigint           not null, primary key
#  page_id    :bigint           not null
#  text       :string
#  x1         :integer
#  x2         :integer
#  y1         :integer
#  y2         :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'test_helper'

class TextItemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
