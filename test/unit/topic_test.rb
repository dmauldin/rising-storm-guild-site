require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  should_have_many :posts
  should_belong_to :forum
  should_validate_presence_of :title
end
