# == Schema Information
# Schema version: 20090409013015
#
# Table name: topics
#
#  id         :integer(4)      not null, primary key
#  title      :string(255)
#  forum_id   :integer(4)
#  locked     :boolean(1)
#  user_id    :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class Topic < ActiveRecord::Base
  belongs_to :forum
  belongs_to :user
  has_many :posts
  
  validates_presence_of :title
  validates_uniqueness_of :title, :scope => :forum_id
end
