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
  belongs_to :image, dependent: :destroy
  # has_many :text_items, dependent: :destroy
  # has_many :page_texts, dependent: :destroy
  has_many :figures, inverse_of: :page, dependent: :destroy
  has_many :ceramics, inverse_of: :page, dependent: :destroy
  has_many :graves, through: :figures
end
