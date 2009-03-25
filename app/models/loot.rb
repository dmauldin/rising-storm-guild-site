# == Schema Information
# Schema version: 20090302152543
#
# Table name: loots
#
#  id         :integer(4)      not null, primary key
#  raid_id    :integer(4)
#  toon_id    :integer(4)
#  mob_id     :integer(4)
#  item_id    :integer(4)
#  looted_at  :datetime
#  created_at :datetime
#  updated_at :datetime
#  primary    :boolean(1)      default(TRUE)
#

class Loot < ActiveRecord::Base
  belongs_to :raid
  belongs_to :toon
  belongs_to :item
  
  named_scope :primary, :conditions => {:status => 'primary'}
  named_scope :secondary, :conditions => {:status => 'secondary'}
  named_scope :banked, :conditions => {:status => 'banked'}
  named_scope :disenchanted, :conditions => {:status => 'disenchanted'}
end
