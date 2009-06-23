require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  should_have_many :loots
end
