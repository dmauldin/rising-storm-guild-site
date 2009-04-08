# == Schema Information
# Schema version: 20090302152543
#
# Table name: skills
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  maxlevel   :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class Skill < ActiveRecord::Base
  has_many :professions
  has_many :toons, :through => :professions
  
  validates_uniqueness_of :name
end
