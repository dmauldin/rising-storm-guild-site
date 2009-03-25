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
  end
  
  namespace :armory do
    task :update_toons, :needs => :environment do
      wowr = Wowr::API.new(WOWR_DEFAULTS)
      guild = wowr.get_guild
      new_members = guild.members.keys - Toon.all.map {|toon| toon.name}
      puts "Found #{guild.members.size} guild members"
      guild.members.each do |name, character|
        toon = Toon.find_by_name(name) || Toon.create(:name => name)
        toon.level = character.level
        toon.job_id = character.klass_id
        toon.gender = character.gender
        toon.race = character.race
        toon.rank = character.rank
        toon.save
      end
      sleep 1.5
      agent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.7.6) Gecko/20050317 Firefox/1.0.2"
      accept = "text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8 "
      charset = "ISO-8859-1,utf-8;q=0.7,*;q=0.7"
      open_options = {
        "User-Agent" => agent,
        "Accept" => accept,
        "Accept-Charset" => charset
      }
      Toon.all.each do |toon|
        achievement_url = "http://www.wowarmory.com/character-achievements.xml?r=Lightbringer&n=#{toon.name}&c=168"
        achievement_xml = open(achievement_url, open_options)
        doc = Hpricot::XML(achievement_xml)
        # normal_glory = doc.at "//achievement[@id='2137']"
        # heroic_glory = doc.at "//achievement[@id='2138']"
        # a = Achievement.find(2137) || Achievement.create(:title => normal_glory[:title], :description => )
        achievements = doc.search "//achievement"
        achievements.each do |a|
          achievement = Achievement.find_by_id(a[:id]) || Achievement.new
          achievement.id = a[:id]
          achievement.title = a[:title]
          achievement.description = a[:desc]
          achievement.category_id = a[:categoryId]
          achievement.points = a[:points]
          achievement.icon = a[:icon]
          achievement.save # this should only save if any columns were changed
          # update completed status for toon here (create toon_achievement)
          if a[:dateCompleted]
            achievement.toon_achievements.create(:toon_id => toon.id, :completed_at => a[:dateCompleted])
          end
          # loop through criteria elements and add links to child achievements
          (a/:criteria).each do |criteria|
            ca = Achievement.find_by_title(criteria[:name])
            if ca
              achievement.criterias.find_by_id(ca) || achievement.criterias << ca
            end
          end
        end
        puts "Processed achievements for #{toon.name}"
        sleep 1.5
      end
    end
    
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
