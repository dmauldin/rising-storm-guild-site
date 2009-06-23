require 'test_helper'

class ForumTest < ActiveSupport::TestCase
  should_have_many :topics
  should_have_many :posts, :through => :topics
  # TODO : figure out why shoulda fails on this next line with no db record
  # should_validate_uniqueness_of :title
  # TODO : rewrite next test to work without has_one association
  # should_have_one :last_post 
end
