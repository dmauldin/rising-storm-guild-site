require 'test_helper'

class ForumTest < ActiveSupport::TestCase
  should_have_one :parent
  should_have_many :topics
  should_validate_uniqueness_of :title
end
