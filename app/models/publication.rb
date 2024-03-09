# == Schema Information
#
# Table name: publications
#
#  id         :bigint           not null, primary key
#  author     :string
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  year       :string
#
class Publication < ApplicationRecord
  has_many :pages, dependent: :destroy
  has_many :figures, through: :pages

  # attribute :site, :string
  has_one_attached :pdf

  def short_description
    "#{author} #{year}"
  end

  def graves
    figures.filter { _1.is_a?(Grave) }
  end
end
