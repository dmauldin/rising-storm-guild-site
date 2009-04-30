require 'test_helper'

class PostTest < ActiveSupport::TestCase
  should_belong_to :user
  should_belong_to :topic
  should_validate_presence_of :user_id
  should_validate_presence_of :topic_id
  should_validate_presence_of :body
end
