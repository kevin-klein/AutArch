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
    include Rails.application.routes.url_helpers

    def href
        image_path(self)
    end
end
