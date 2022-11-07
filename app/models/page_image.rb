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
class PageImage < ApplicationRecord
  belongs_to :page
  belongs_to :image
  has_many :figures
end
