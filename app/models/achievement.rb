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
    Toon.raiders - self.toons_with_achievement
    
  end
  
  def toons_with_achievement
    self.toons.raiders
  end
end
