# == Schema Information
# Schema version: 20081219192707
#
# Table name: loots
#
#  id         :integer         not null, primary key
#  raid_id    :integer
#  toon_id    :integer
#  mob_id     :integer
#  item_id    :integer
#  looted_at  :datetime
#  created_at :datetime
#  updated_at :datetime
#  primary    :boolean         default(TRUE)
#

class Loot < ActiveRecord::Base
  belongs_to :raid
  belongs_to :toon
  belongs_to :item
end
