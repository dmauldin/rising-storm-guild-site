# == Schema Information
# Schema version: 20090409013015
#
# Table name: achievements
#
#  id          :integer(4)      not null, primary key
#  title       :string(255)     not null
#  description :string(255)
#  category_id :integer(4)
#  icon        :string(255)
#  points      :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#

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
  has_many :toons, :through => :toon_achievements, :include => :job

  attr_accessible :title, :description, :category_id, :icon, :points
  
  def raiders_without_achievement
    Toon.raiders - self.raiders_with_achievement
  end
  
  def raiders_with_achievement
    self.toons & Toon.raiders
  end

  def toons_without_achievement
    Toon.all - self.toons_with_achievement
  end
  
  def toons_with_achievement
    self.toons
  end
end
