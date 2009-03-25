class AchievementsController < ApplicationController
  def index
    @achievements = Achievement.find([2137, 2138]).collect {|a| a.criterias}.flatten
  end
end
