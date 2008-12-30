class RaidsController < ApplicationController
  def index
    @raids = Raid.all(:order => 'start_at')
  end
  
  def show
    @raid = Raid.find(params[:id])
  end
end
