# == Schema Information
# Schema version: 20090409013015
#
# Table name: posts
#
#  id         :integer(4)      not null, primary key
#  title      :string(255)
#  topic_id   :integer(4)
#  user_id    :integer(4)
#  body       :text
#  created_at :datetime
#  updated_at :datetime
#  toon_id    :integer(4)
#

class Post < ActiveRecord::Base
  belongs_to :topic
  belongs_to :user
  belongs_to :toon
end
