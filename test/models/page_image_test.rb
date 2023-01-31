# == Schema Information
#
# Table name: page_images
#
#  id         :bigint           not null, primary key
#  page_id    :bigint           not null
#  image_id   :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'test_helper'

class PageImageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
