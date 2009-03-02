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
end
