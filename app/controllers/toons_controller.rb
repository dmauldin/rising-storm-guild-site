class ToonsController < ApplicationController
  def index
    @toons = Toon.all(:order => 'name', :include => [:job])
  end
end
