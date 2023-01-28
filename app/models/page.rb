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
class Page < ApplicationRecord
  belongs_to :publication
  belongs_to :image
  has_many :text_items
  has_many :page_texts
  has_many :figures
  has_many :graves, through: :figures
end
