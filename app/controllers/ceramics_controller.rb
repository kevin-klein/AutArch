class CeramicsController < ApplicationController
  def index
    @ceramics = Ceramic.where.not(parent_id: nil).includes(:grave).order(:id)
  end
end
