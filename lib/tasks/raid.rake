require 'rubygems'
require 'hpricot'

namespace :raid do
  task :import, :raid_file, :needs => :environment do |t, args|
    # import raid from xml
    unless args.raid_file && FileTest.exists?(args.raid_file)
      puts "You need to specify a file to import raid tracker data from."
    else
      puts "Importing raid from XML"

      doc = Hpricot.XML(open(args.raid_file))

      # zone_name = (doc/"RaidInfo/Zone").innerHTML
      # zone = (Zone.find_by_name(zone_name) || Zone.create(:name => zone_name))
      
      raid_key   = (doc/"RaidInfo/key").innerHTML.to_time
      raid = Raid.find_by_key(raid_key)
      if raid
        puts "Raid already exists, exiting."
      else
        raid_start = (doc/"RaidInfo/start").innerHTML.to_time
        raid_end   = (doc/"RaidInfo/end").innerHTML.to_time
        raid = Raid.create(:key => raid_key, :start_at => raid_start, :end_at => raid_end)
      
        loots = doc.at(:Loot).containers

        loots.each do |loot|
          item_id = (loot/"ItemID").innerHTML.split(":")[0]
          item_name = (loot/"ItemName").innerHTML
          player_name = (loot/"Player").innerHTML
          loot_time = (loot/"Time").innerHTML.to_time
          primary = (loot/"Costs").innerHTML=="0" ? true : false
          
          unless player_name == "disenchant" || player_name == "bank" || item_name == "Abyss Crystal"
            item = Item.find_by_id(item_id)
            unless item
              item = Item.new
              item.name = item_name
              item.id = item_id
            end
            toon = Toon.find_by_name(player_name) || Toon.create(:name => player_name)
            raid.loots.create(:toon_id => toon.id, :item_id => item.id,
                              :looted_at => loot_time, :primary => primary)
          end
        end
      end
    end
  end
end
