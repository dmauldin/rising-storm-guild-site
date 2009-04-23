# == Schema Information
# Schema version: 20090409013015
#
# Table name: toon_achievements
#
#  id             :integer(4)      not null, primary key
#  toon_id        :integer(4)      not null
#  achievement_id :integer(4)      not null
#  completed_at   :datetime
#  created_at     :datetime
#  updated_at     :datetime
#

class ToonAchievement < ActiveRecord::Base
  belongs_to :toon
  belongs_to :achievement
  validates_uniqueness_of :achievement_id, :scope => :toon_id
end
