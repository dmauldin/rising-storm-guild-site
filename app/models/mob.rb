# == Schema Information
# Schema version: 20090302152543
#
# Table name: mobs
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  zone_id    :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class Mob < ActiveRecord::Base
end
