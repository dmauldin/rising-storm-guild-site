class ToonAchievement < ActiveRecord::Base
  belongs_to :toon
  belongs_to :achievement
end
