# == Schema Information
#
# Table name: publications
#
#  id         :bigint           not null, primary key
#  pdf        :binary
#  author     :string
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Publication < ApplicationRecord
  has_many :pages, dependent: :destroy
  has_many :graves, through: :pages
  has_many :page_texts, dependent: :destroy

  attribute :site, :string
end
