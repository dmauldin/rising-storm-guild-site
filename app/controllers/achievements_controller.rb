class AchievementsController < ApplicationController
  def index
    @normal_achievements = Achievement.find(2137, :include => {:criterias => :toons}).criterias
    @heroic_achievements = Achievement.find(2138, :include => {:criterias => :toons}).criterias
    @total_toons = Toon.raiders.size.to_f
  end
  
  def show
    @achievement = Achievement.find(params[:id], :include => :toons)
  end
end
