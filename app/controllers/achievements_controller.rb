class AchievementsController < ApplicationController
  caches_page :index
  def index
    @normal_achievements = Achievement.find(2137, :include => {:criterias => :toons}).criterias
    @heroic_achievements = Achievement.find(2138, :include => {:criterias => :toons}).criterias
    @total_toons = Toon.raiders.count.to_f
  end
end
