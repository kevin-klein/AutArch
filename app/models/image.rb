# == Schema Information
#
# Table name: images
#
#  id         :integer          not null, primary key
#  data       :binary
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  width      :integer
#  height     :integer
#
class Image < ApplicationRecord
  include Rails.application.routes.url_helpers

  def href
    "/uploads/images/#{id}.jpg"
  end

  def data
    File.binread(Rails.root.join("public/uploads/images/#{id}.jpg").to_s)
  end
end
