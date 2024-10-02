# == Schema Information
#
# Table name: images
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  width      :integer
#  height     :integer
#
class Image < ApplicationRecord
  include Rails.application.routes.url_helpers

  after_destroy :delete_file

  has_one :page, dependent: :destroy

  has_one_attached :data

  def file_path
    Rails.root.join("images/#{id}.jpg").to_s
  end

  def url
    page_image_path(id)
  end

  def delete_file
    File.delete(file_path)
  end
end
