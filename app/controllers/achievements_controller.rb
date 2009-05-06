class AchievementsController < ApplicationController
  def index
    # @normal_achievements = Achievement.find(2137, :include => {:criterias => {:toons => :job}}).criterias
    # @heroic_achievements = Achievement.find(2138, :include => {:criterias => {:toons => :job}}).criterias
    # @total_toons = Toon.raiders(:include => :job).size.to_f
    @achievements = Achievement.all
  end
  
  def show
    @achievement = Achievement.find(params[:id], :include => :toons)
  end
end
