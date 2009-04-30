class Forum < ActiveRecord::Base
  has_many :topics
  has_many :posts, :through => :topics
  
  validates_presence_of :title
  validates_uniqueness_of :title
  
  def last_post
    posts.find(:first, :order => "updated_at desc")
  end
end
