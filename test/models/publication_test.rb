# == Schema Information
#
# Table name: publications
#
#  id         :bigint           not null, primary key
#  pdf        :binary
#  author     :string
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'test_helper'

class PublicationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
