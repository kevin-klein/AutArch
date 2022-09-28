class Page < ApplicationRecord
  belongs_to :publication
  belongs_to :image
  has_many :figures
end
