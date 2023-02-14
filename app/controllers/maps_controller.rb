class MapsController < ApplicationController
  def index
    @maps = Map.all
  end
end
