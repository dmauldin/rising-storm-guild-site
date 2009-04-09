class ToonsController < ApplicationController
  def index
    @normal_achievements = Achievement.find_by_id(2137, :include => {:criterias => :toons}).criterias
    @heroic_achievements = Achievement.find_by_id(2138, :include => {:criterias => :toons}).criterias
    
    #@skills = Skill.all(:conditions => {:name => ['alchemy', 'tailoring', 'leatherworking', 'skinning', 'enchanting', 'herbalism', 'blacksmithing', 'mining', 'jewelcrafting', 'engineering']}, :order => 'name asc')

    @search = Toon.new_search(params[:search])
    @search.conditions.deleted_not = true
    @search.conditions.rank_not = nil
    @search.conditions.rank ||= [0,2,3,4]
    #@search.conditions.professions.skill.name ||= @skills.map{|s| s[:name]}
    @search.per_page = 50
    @search.order_by = [:rank, :name]
    @toons, @toons_count = @search.all, @search.count

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @toons }
    end
  end
end
