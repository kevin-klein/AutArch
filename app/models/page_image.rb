class PageImage < ApplicationRecord
  belongs_to :page
  belongs_to :image
  has_many :figures
end
