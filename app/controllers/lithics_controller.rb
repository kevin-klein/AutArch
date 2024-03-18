class LithicsController < ApplicationController
  def index
    @lithics = StoneTool.where('probability > ?', 0.3)
  end

  def show
    @lithic = StoneTool.find(params[:id])
  end
end
