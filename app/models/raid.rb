# == Schema Information
# Schema version: 20090302152543
#
# Table name: raids
#
#  id         :integer(4)      not null, primary key
#  start_at   :datetime
#  end_at     :datetime
#  zone_id    :integer(4)
#  note       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  key        :string(255)
#

class Raid < ActiveRecord::Base
  has_many :loots, :dependent => :destroy
  belongs_to :zone
  has_many :attendances
  has_many :toons, :through => :attendances
  
  validates_uniqueness_of :key
  validates_presence_of :key
  validates_presence_of :start_at
  validates_presence_of :zone_id
  
  def formatted_start_at
    self.start_at.to_s(:raid)
  end
  
  def self.create_from_xml(xml)
    begin
      raid = self.new
      doc = Hpricot::XML(xml)
      # TODO: throw error on invalid xml
    
      zone_name = (doc/"raidinfo/zone").inner_text
    
      instance_id = (doc/"raidinfo/instanceid").inner_text.to_i
      raid.key      = instance_id
      raid.start_at = Time.at((doc/"raidinfo/start").inner_text.to_i)
      raid.end_at   = Time.at((doc/"raidinfo/end").inner_text.to_i)
      raid.zone     = (Zone.find_by_name(zone_name) || Zone.create(:name => zone_name))
      raid.save!
    
      (doc/"playerinfos/player").each do |player|
        player_name = (player/"name").inner_text
        # player/"class" is the wow class id, our db was manipulated to also use as id
        toon = Toon.find_or_create_by_name(:name => player_name, :job_id => Job::MLDKP_TRANS[(player/"class").inner_text.to_i], :level => 80)
        raise "Unable to create toon with name:'#{player_name}' and job_id:'#{Job::MLDKP_TRANS[(player/"class").inner_text.to_i]}'" if toon.new_record?
        raid.attendances.create(:toon_id => toon.id)
      end

      (doc/:loot).each do |loot|
        note = loot/:note
        unless (note.length>0) && %w(d b).include?(note.inner_text) # disenchanted or banked
          item_id     = (loot/"itemid").inner_text.split(":")[0]
          item_name   = (loot/"itemname").inner_text
          player_name = (loot/"player").inner_text
          loot_time   = Time.at((loot/"time").inner_text.to_i)
          status      = (loot/"note").inner_text == "s" ? "secondary" : "primary"
          mob_name    = (loot/"boss").inner_text
        
          unless player_name == "disenchant" || player_name == "bank"
            item = Item.find_by_id(item_id)
            unless item
              item      = Item.new
              item.name = item_name
              item.id   = item_id
              item.save
            end
            mob = Mob.find_by_name(mob_name) || Mob.create(:name => mob_name, :zone_id => raid.zone.id)
            toon = Toon.find_by_name(player_name) # already in db from attendance loop
            unless Loot.find(:first, :conditions => {:toon_id => toon.id,
                :item_id => item.id, :looted_at_after => loot_time - 3,
                :looted_at_before => loot_time + 3, :mob_id => mob.id})
              raid.loots.create(:toon_id => toon.id, :item_id => item.id,
                  :looted_at => loot_time, :status => status, :mob_id => mob.id)
            end
          end # player_name = disenchanted or banked
        end # note = d or b
      end # each loot
      return raid
    end
  end
end
