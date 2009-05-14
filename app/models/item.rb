# == Schema Information
# Schema version: 20090302152543
#
# Table name: items
#
#  id                 :integer(4)      not null, primary key
#  name               :string(255)
#  wow_id             :integer(4)
#  icon               :string(255)
#  level              :integer(4)
#  quality            :integer(4)
#  item_type          :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  token_cost_id      :integer(4)
#  cost               :integer(4)
#  honor_cost         :integer(4)
#  subclass_name      :string(255)
#  inventory_type     :integer(4)
#  required_level     :integer(4)
#  armory_item_xml    :text
#  armory_tooltip_xml :text
#  armory_updated_at  :datetime
#

class Item < ActiveRecord::Base
  has_many :loots, :dependent => :destroy
  belongs_to :token_cost, :class_name => 'Item'
  
  def currency_for
    Item.all(:conditions => {:token_cost_id => self.id})
  end
  
  def update_from_armory!
    update_from_armory
    save
  end

  # can't remember why I split the save off into a different method
  def update_from_armory
    wowr = Wowr::API.new(WOWR_DEFAULTS)
    begin
      # no need to check if the assignment succeeded.  raises error if not
      item_info = wowr.get_item_info(self.id)
      self.name = item_info.name
      self.level = item_info.level

      item_tooltip = wowr.get_item_tooltip(self.id)
      self.inventory_type = item_tooltip.equip_data.inventory_type
      self.subclass_name = item_tooltip.equip_data.subclass_name
      self.required_level = item_tooltip.required_level
      
      self.armory_updated_at = Time.now
    # TODO should specifically rescue Wowr item not found errors
    rescue
      false
    end
  end
  
  INV_TYPE_HASH = {
    1 => "Head",
    2 => "Neck",
    3 => "Shoulder",
    4 => "Shirt",
    5 => "Chest",
    6 => "Waist",
    7 => "Legs",
    8 => "Feet",
    9 => "Wrist",
    10 => "Hands",
    11 => "Ring",
    12 => "Trinket",
    13 => "One-Hand",
    14 => "Off-Hand",
    15 => "Ranged",
    16 => "Back",
    17 => "Two-Hand",
    21 => "Main-Hand",
    23 => "Held in off-hand",
    26 => "Wand",
    28 => "Ranged",
  }

  SUBCLASSES = ["Plate", "Dagger", "Mail", "Cloth", "Leather", "Staff",
    "Totem", "Wand", "Sword", "Mace", "Idol", "Libram", "Fist Weapon",
    "Shield", "Sigil", "Axe", "Bag", "Polearm", "Crossbow", "Thrown", "Bow"]
end
