class AchievementsController < ApplicationController
  def index
    @achievements = Achievement.find([2137, 2138], :include => {:criterias => :toons}).collect {|a| a.criterias}.flatten
  end
end
