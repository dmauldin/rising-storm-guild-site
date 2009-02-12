namespace :site do
  namespace :init do
    task :jobs, :needs => :environment do
      [["Priest",       "#FFFFFF", 5],
      ["Warrior",       "#C79C6E", 1],
      ["Mage",          "#69CCF0", 8],
      ["Warlock",       "#9482C9", 9],
      ["Hunter",        "#ABD473", 3],
      ["Shaman",        "#2459FF", 7],
      ["Druid",         "#FF7D0A", 11],
      ["Paladin",       "#F58CBA", 2],
      ["Death Knight",  "#C41F3B", 6],
      ["Rogue",         "#FFF569", 4]].each do |class_array|
        class_name, class_color, wow_id = class_array
        job = Job.new(:name => class_name, :color => class_color)
        job.id = wow_id
        job.save
      end
    end

    task :toons, :needs => :environment do
      # get list of guild members from armory for guild/realm
      # create new Toon for each record
    end
  end
  
  namespace :update do
    task :toons, :needs => :environment do
      Toon.all.each do |toon|
        puts "Updating #{toon.name}"
        toon.update_from_armory
        toon.save
      end
    end
  end
  
  namespace :armory do
    task :update_item_xml, :needs => :environment do
      agent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.7.6) Gecko/20050317 Firefox/1.0.2"
      accept = "text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8 "
      charset = "ISO-8859-1,utf-8;q=0.7,*;q=0.7"
      info_url = "http://www.wowarmory.com/item-info.xml?i="
      tooltip_url = "http://www.wowarmory.com/item-tooltip.xml?i="
      open_options = {
        "User-Agent" => agent,
        "Accept" => accept,
        "Accept-Charset" => charset
      }
      attributes_to_check = ['armory_item_xml', 'armory_tooltip_xml']
      Item.all.each do |item|
        next if item.armory_updated_at && (item.armory_updated_at > 1.week.ago)
        puts "Updating [#{item.id}] #{item.name}"
        info = open("#{info_url}#{item.id}", open_options)
        sleep 1.5
        item.armory_item_xml = info.read if info.status[0] == "200"
        tooltip = open("#{tooltip_url}#{item.id}", open_options)
        sleep 1.5
        item.armory_tooltip_xml = tooltip.read if tooltip.status[0] == "200"
        if (item.changed & attributes_to_check).length > 0
          item.armory_updated_at = Time.now
          item.save
        end
      end
    end
  end
end
