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

  def update_from_armory
    wowr = Wowr::API.new(WOWR_DEFAULTS)
    begin
      item_info = wowr.get_item_info(self.id)
      if item_info
        self.level = item_info.level
      end

      item_tooltip = wowr.get_item_tooltip(self.id)
      if item_tooltip
        self.inventory_type = item_tooltip.equip_data.inventory_type
        self.subclass_name = item_tooltip.equip_data.subclass_name
        self.required_level = item_tooltip.required_level
      end
      logger.debug("Item updated!")
      return true
    rescue
      logger.debug("Uhh, something went wrong")
      return false
    end
  end
end
