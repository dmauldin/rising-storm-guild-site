class RaidsController < ApplicationController
  def index
    @raids = Raid.all(:order => 'start_at')
  end
  
  def show
    @raid = Raid.find(params[:id])
  end
  
  def new
    @raid = Raid.new
  end
  
  def create
    unless params[:raid_xml]
      flash[:error] = "Raid XML field cannot be empty"
      redirect_to new_raid_path
      return
    end
    @raid = Raid.create_from_xml(params[:raid_xml])
    flash[:notice] = "New raid created."
    redirect_to raids_path
  end
end
