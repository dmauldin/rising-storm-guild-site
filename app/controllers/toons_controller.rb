class ToonsController < ApplicationController
  def index
    @toons = Toon.all(:order => 'name')
  end
end
