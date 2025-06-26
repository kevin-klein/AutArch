class CeramicsController < ApplicationController
  def index
    @ceramics = Ceramic.where.not(parent_id: nil).order(:id)
  end

  def show
    @ceramic = Ceramic.find(params[:id])
  end
end
