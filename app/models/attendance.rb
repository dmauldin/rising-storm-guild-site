# == Schema Information
# Schema version: 20090302152543
#
# Table name: attendances
#
#  id         :integer(4)      not null, primary key
#  toon_id    :integer(4)
#  raid_id    :integer(4)
#  sat        :boolean(1)
#  joined_at  :datetime
#  parted_at  :datetime
#  created_at :datetime
#  updated_at :datetime
#

class Attendance < ActiveRecord::Base
  belongs_to :toon
  belongs_to :raid
  
  validates_presence_of :toon_id
  validates_presence_of :raid_id
  
  attr_accessible :toon_id, :raid_id, :sat, :joined_at, :parted_at
end
