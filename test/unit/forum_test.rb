require 'test_helper'

class ForumTest < ActiveSupport::TestCase
  should_have_many :topics
  should_validate_presence_of :title
  should_have_one :last_post
end
