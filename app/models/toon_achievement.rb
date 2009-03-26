class ToonAchievement < ActiveRecord::Base
  belongs_to :toon
  belongs_to :achievement
  validates_uniqueness_of :achievement_id, :scope => :toon_id
end
