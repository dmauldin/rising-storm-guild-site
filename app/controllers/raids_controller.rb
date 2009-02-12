class RaidsController < ApplicationController
  before_filter :admin_only
  
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
  
  # DELETE /raids/1
  # DELETE /raids/1.xml
  def destroy
    @raid = Raid.find(params[:id])
    @raid.destroy

    respond_to do |format|
      format.html { redirect_to(raids_url) }
      format.xml  { head :ok }
    end
  end
end
