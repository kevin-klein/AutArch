class SharePublication < ApplicationRecord
  belongs_to :publication
  belongs_to :user
end
