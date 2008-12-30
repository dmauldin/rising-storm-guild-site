# == Schema Information
# Schema version: 20081219192707
#
# Table name: mobs
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  zone_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class Mob < ActiveRecord::Base
end
