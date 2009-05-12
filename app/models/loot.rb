# == Schema Information
# Schema version: 20090409013015
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
#  status     :string(255)
#

class Loot < ActiveRecord::Base
  belongs_to :raid
  belongs_to :toon
  belongs_to :item
  belongs_to :mob
  
  STATUSES = %w(primary secondary banked disenchanted)

  validates_inclusion_of :status, :in => STATUSES
  
  named_scope :primary, :conditions => {:status => 'primary'}
  named_scope :secondary, :conditions => {:status => 'secondary'}
  named_scope :banked, :conditions => {:status => 'banked'}
  named_scope :disenchanted, :conditions => {:status => 'disenchanted'}
end
