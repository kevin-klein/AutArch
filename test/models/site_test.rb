# == Schema Information
#
# Table name: sites
#
#  id           :bigint           not null, primary key
#  lat          :float
#  lon          :float
#  name         :string
#  locality     :string
#  country_code :integer
#  site_code    :string
#
require 'test_helper'

class SiteTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
