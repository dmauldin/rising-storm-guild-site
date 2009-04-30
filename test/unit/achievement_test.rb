require 'test_helper'

class AchievementTest < ActiveSupport::TestCase
  should_have_many :toon_achievements
  should_have_many :toons, :through => :toon_achievements
end
