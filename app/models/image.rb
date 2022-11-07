# == Schema Information
#
# Table name: images
#
#  id         :bigint           not null, primary key
#  data       :binary
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Image < ApplicationRecord
end
