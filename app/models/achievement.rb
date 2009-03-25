class Achievement < ActiveRecord::Base
  has_and_belongs_to_many :criterias, 
                          :join_table => "achievement_criterias",
                          :foreign_key => "achievement_id",
                          :association_foreign_key => "criteria_id",
                          :class_name => "Achievement",
                          :order => "title asc"
  has_and_belongs_to_many :metas,
                          :join_table => "achievement_criterias",
                          :foreign_key => "criteria_id",
                          :association_foreign_key => "achievement_id",
                          :class_name => "Achievement",
                          :order => "title asc"
  has_many :toon_achievements
  has_many :toons, :through => :toon_achievements

  def toons_without_achievement
    toons = Toon.all(:conditions => { :rank => 0..4 }) # GM through Trial
    toons.reject{|toon| self.toons.include?(toon)}
  end
end