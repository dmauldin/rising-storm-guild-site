require 'test_helper'

class ToonTest < ActiveSupport::TestCase
  should_belong_to :user
  should_have_many :loots
  should_have_many :professions
  should_have_many :achievements, :through => :toon_achievements
  should_belong_to :job
  should_have_many :attendances
  should_have_many :raids, :through => :attendances
  should_have_many :posts
  should_have_many :specs, :through => :toon_specs

  should_validate_presence_of :name
  should_validate_presence_of :job
  should_ensure_value_in_range :level, 1..80
end
