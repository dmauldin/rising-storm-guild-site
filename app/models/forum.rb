class Forum < ActiveRecord::Base
  has_many :topics
  has_many :posts, :through => :topics
  
  validates_uniqueness_of :title
end
