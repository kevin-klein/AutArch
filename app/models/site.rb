# == Schema Information
#
# Table name: sites
#
#  id   :bigint           not null, primary key
#  lat  :float
#  lon  :float
#  name :string
#
class Site < ApplicationRecord
  has_many :graves
end
