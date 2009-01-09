# == Schema Information
# Schema version: 20081219192707
#
# Table name: raids
#
#  id         :integer         not null, primary key
#  start_at   :datetime
#  end_at     :datetime
#  zone_id    :integer
#  note       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  key        :string(255)
#

class Raid < ActiveRecord::Base
  has_many :loots
  
  def formatted_start_at
    self.start_at.to_s(:raid)
  end
  
  def self.create_from_xml(xml)
    raid = self.new
    doc = Hpricot::XML(xml)
    # TODO: throw error on invalid xml
    
    # zone_name = (doc/"RaidInfo/Zone").innerHTML
    # zone = (Zone.find_by_name(zone_name) || Zone.create(:name => zone_name))
    
    raid_key   = (doc/"RaidInfo/key").innerHTML.to_time
    if Raid.find_by_key(raid_key)
      # TODO: throw error if raid has already been imported
    else
      raid.key = raid_key
      raid.start_at = (doc/"RaidInfo/start").innerHTML.to_time
      raid.end_at = (doc/"RaidInfo/end").innerHTML.to_time
      raid.save
      
      loots = doc.at(:Loot).containers

      loots.each do |loot|
        item_id = (loot/"ItemID").innerHTML.split(":")[0]
        item_name = (loot/"ItemName").innerHTML
        player_name = (loot/"Player").innerHTML
        loot_time = (loot/"Time").innerHTML.to_time
        primary = (loot/"Costs").innerHTML=="0" ? true : false
        
        unless player_name == "disenchant" || player_name == "bank"
          item = Item.find_by_id(item_id)
          unless item
            item = Item.new
            item.name = item_name
            item.id = item_id
            item.save
          end
          toon = Toon.find_by_name(player_name) || Toon.create(:name => player_name)
          raid.loots.create(:toon_id => toon.id, :item_id => item.id,
                            :looted_at => loot_time, :primary => primary)
        end
      end
    end
    return raid
  end
end
