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
  has_many :pages
  has_many :graves, through: :pages

  attribute :site, :string
end
