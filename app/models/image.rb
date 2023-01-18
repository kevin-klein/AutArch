# == Schema Information
#
# Table name: images
#
#  id         :bigint           not null, primary key
#  data       :binary
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  width      :integer
#  height     :integer
#
class Image < ApplicationRecord
end
