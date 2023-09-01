# == Schema Information
#
# Table name: page_texts
#
#  id         :integer          not null, primary key
#  page_id    :integer          not null
#  text       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class PageText < ApplicationRecord
  belongs_to :page
end
