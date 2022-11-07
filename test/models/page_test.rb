# == Schema Information
#
# Table name: pages
#
#  id             :bigint           not null, primary key
#  publication_id :bigint           not null
#  number         :integer
#  image_id       :bigint           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
require "test_helper"

class PageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
