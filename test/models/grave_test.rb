# == Schema Information
#
# Table name: graves
#
#  id         :bigint           not null, primary key
#  location   :string
#  figure_id  :integer          not null
#  site_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  arc_length :float
#  area       :float
#  kurgan_id  :bigint
#
require "test_helper"

class GraveTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
