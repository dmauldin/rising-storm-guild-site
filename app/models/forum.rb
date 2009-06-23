# == Schema Information
# Schema version: 20090409013015
#
# Table name: forums
#
#  id           :integer(4)      not null, primary key
#  title        :string(255)
#  description  :text
#  parent_id    :integer(4)
#  allow_topics :boolean(1)
#  created_at   :datetime
#  updated_at   :datetime
#

class Forum < ActiveRecord::Base
  acts_as_tree
  has_many :topics, :dependent => :destroy
  has_many :posts, :through => :topics

  validates_presence_of :title
  validates_uniqueness_of :title
  
  def last_post
    posts.first(:order => "updated_at desc")
  end
end
