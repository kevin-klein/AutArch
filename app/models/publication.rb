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
#  user_id    :bigint
#  public     :boolean          default(FALSE), not null
#
class Publication < ApplicationRecord
  has_many :pages, dependent: :destroy
  has_many :figures, through: :pages
  has_many :ceramics, through: :pages

  belongs_to :user, optional: true

  has_many :share_publications, dependent: :destroy
  has_many :shared_with, through: :share_publications

  has_one_attached :pdf

  def short_description
    "#{author} #{year}"
  end

  def graves
    figures.filter { _1.is_a?(Grave) }
  end
end
