class ToonsController < ApplicationController
  def index
    @search = Toon.new_search(params[:search])
    @search.conditions.deleted_not = true
    @search.conditions.rank_not = nil
    @search.conditions.rank = [0,2,3,4] unless @search.conditions.rank
    @search.per_page = 50
    @search.order_by = [:rank, :name]
    @toons, @toons_count = @search.all, @search.count
    
    @normal_achievements = Achievement.find(2137, :include => {:criterias => :toons}).criterias
    @heroic_achievements = Achievement.find(2138, :include => {:criterias => :toons}).criterias
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @toons }
    end
  end
end
