require 'test_helper'

class AttendanceTest < ActiveSupport::TestCase
  should_belong_to :toon
  should_belong_to :raid
  
  should_validate_presence_of :toon_id
  should_validate_presence_of :raid_id
end
