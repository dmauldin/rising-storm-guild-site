require 'test_helper'

class RaidTest < ActiveSupport::TestCase
  should_have_many :loots
  should_have_many :attendances
  should_have_many :toons, :through => :attendances
  should_belong_to :zone
  
  should_validate_presence_of :zone_id
  should_validate_presence_of :instance_id
  should_validate_presence_of :start_at
end
