# == Schema Information
#
# Table name: page_texts
#
#  id         :bigint           not null, primary key
#  page_id    :bigint           not null
#  text       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'test_helper'

class PageTextTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
