class ToonsController < ApplicationController
  def index
    @toons = Toon.all(:order => 'rank asc, name asc', :include => [:job], :conditions => {:deleted => false})
  end
end
