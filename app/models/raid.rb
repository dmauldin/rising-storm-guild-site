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
  has_many :loots, :dependent => :destroy
  belongs_to :zone
  
  def formatted_start_at
    self.start_at.to_s(:raid)
  end
  
  def self.create_from_xml(xml)
    raid = self.new
    doc = Hpricot::XML(xml)
    # TODO: throw error on invalid xml
    
    zone_name = (doc/"raidinfo/zone").inner_text
    
    instance_id = (doc/"raidinfo/instanceid").inner_text.to_i
    if Raid.find_by_key(instance_id)
      # TODO: throw error if raid has already been imported
    else
      raid.key      = instance_id
      raid.start_at = Time.at((doc/"raidinfo/start").inner_text.to_i)
      raid.end_at   = Time.at((doc/"raidinfo/end").inner_text.to_i)
      raid.zone     = (Zone.find_by_name(zone_name) || Zone.create(:name => zone_name))
      raid.save
      
      (doc/:loot).each do |loot|
        note = loot/:note
        unless (note.length>0) && %w(d b).include?(note.inner_text) # disenchanted or banked
          item_id     = (loot/"itemid").inner_text.split(":")[0]
          item_name   = (loot/"itemname").inner_text
          player_name = (loot/"player").inner_text
          loot_time   = (loot/"time").inner_text
          primary     = (loot/"note").inner_text == "s" ? false : true
        
          unless player_name == "disenchant" || player_name == "bank"
            item = Item.find_by_id(item_id)
            unless item
              item      = Item.new
              item.name = item_name
              item.id   = item_id
              item.save
            end
            toon = Toon.find_by_name(player_name) || Toon.create(:name => player_name)
            raid.loots.create(:toon_id => toon.id, :item_id => item.id,
                              :looted_at => loot_time, :primary => primary)
          end # player_name = disenchanted or banked
        end # note = d or b
      end # each loot
    end
    return raid
  end
end
