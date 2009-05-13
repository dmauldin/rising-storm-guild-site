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
  
  task :verify_defaults, :needs => :environment do
    Toon.all.each do |toon|
      toon.update_attribute(:wants_achievements, false) if toon.wants_achievements.nil?
      toon.update_attribute(:deleted, false) if toon.deleted.nil?
    end
    User.all.each do |user|
      user.update_attribute(:wants_achievements, false) if user.wants_achievements.nil?
    end
  end

  namespace :armory do
    task :update_toons, :needs => :environment do
      do_professions = false
      do_achievements = true
      armory_throttle_time = 1.5
      def time_to_usec(time)
        (time.usec.to_f / 1000000) + time.sec + (time.min*60) + (time.hour*3600)
      end
      def current_time
        time_to_usec(Time.new)
      end
      def wait_until(dest_time)
        while dest_time > current_time do
          sleep 0.1
        end
        return current_time
      end
      def log(event)
        LogEntry.create(:comment => event)
      end
      wowr = Wowr::API.new(WOWR_DEFAULTS.merge(:debug => true))
      last_open = current_time
      guild = wowr.get_guild
      new_members = guild.members.keys - Toon.all.map {|toon| toon.name}
      log "Found #{new_members.size} new guild members."
      log "Processing #{guild.members.size} guild members."
      guild.members.each do |name, character|
        log "Processing #{character.name}"
        toon = Toon.find_by_name(name) || Toon.create(:name => name)
        toon.level = character.level
        toon.job_id = character.klass_id
        toon.gender = character.gender
        toon.race = character.race
        toon.rank = character.rank
        toon.save
        # wow armory request throttling
        if do_professions # process professions
          # guild.members apparently doesn't return full character records
          begin
            last_open = wait_until(last_open + armory_throttle_time)
            wc = wowr.get_character(character.name)
            log "Armory data obtained for #{character.name}"
            # remove professions the character no longer has
            toon.professions.each do |toon_prof|
              unless wc.professions.map{|p|p.key}.include?(toon_prof.skill.name)
                toon_prof.destroy
                log "#{toon.name} has dropped the #{toon_prof.skill.name.capitalize} profession."
              end
            end
            # find or create the toon's profession, then update stats from armory
            wc.professions.each do |prof|
              # find or create the skill
              skill = Skill.find_by_name(prof.key)
              log "Found new skill, #{prof.key.capitalize}" unless skill
              skill ||= Skill.create(:name => prof.key, :maxlevel => prof.max)
              # bump the max level up if we need to
              log "Found new max level (#{prof.max}) for #{prof.key.capitalize}" if prof.max > skill.maxlevel
              skill.update_attribute(:maxlevel, prof.max) if prof.max > skill.maxlevel
              # create or update the toon's profession
              toon_prof = toon.professions.find_by_skill_id(skill[:id])
              log "#{toon.name} has gained the #{prof.key.capitalize} profession at #{prof.value} skill." unless toon_prof
              toon_prof ||= toon.professions.create(:skill_id => skill[:id], :maxlevel => prof.max, :level => prof.value)
              log "#{toon.name} has gone from #{toon_prof.level} to #{prof.value} in #{prof.key.capitalize}" if prof.value > toon_prof.level
              toon_prof.maxlevel = prof.max
              toon_prof.level = prof.value
              toon_prof.save if toon_prof.changed?
            end
          rescue Wowr::Exceptions::CharacterNoInfos
            log "Character #{character.name} failed to load from Armory"
          end
        end
      end
      if do_achievements # process achievements
        # wowr does't have a way to grab achievements yet, so we do this manually
        agent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.7.6) Gecko/20050317 Firefox/1.0.2"
        accept = "text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8 "
        charset = "ISO-8859-1,utf-8;q=0.7,*;q=0.7"
        open_options = {
          "User-Agent" => agent,
          "Accept" => accept,
          "Accept-Charset" => charset
        }
        Toon.all.each do |toon|
          # if a new achievement is found, it needs to be added to all achievements
          # for now, we'll just get the whole thing every time
          # better than getting each achievement as it comes up every time
          all_achievements = Achievement.find(:all, :include => [:criterias, :toon_achievements])
          achievement_url = "http://www.wowarmory.com/character-achievements.xml?r=Lightbringer&n=#{toon.name}&c=168"
          last_open = wait_until(last_open + armory_throttle_time)
          begin
            achievement_xml = open(URI.escape(achievement_url), open_options)
            doc = Hpricot::XML(achievement_xml)
            # normal_glory = doc.at "//achievement[@id='2137']"
            # heroic_glory = doc.at "//achievement[@id='2138']"
            # a = Achievement.find(2137) || Achievement.create(:title => normal_glory[:title], :description => )
            achievements = doc.search "//achievement"
            achievements.each do |a|
              # get and update the actual achievement record from the db
              achievement = all_achievements.select{|aa| aa[:id] == a[:id].to_i}.first
              achievement = Achievement.new if achievement.nil?
              # achievement = Achievement.find_by_id(a[:id], :include => [:criterias, :toon_achievements]) || Achievement.new
              achievement.id = a[:id] unless achievement.id == a[:id]
              achievement.title = a[:title] unless achievement.title == a[:title]
              achievement.description = a[:desc] unless achievement.description = a[:desc]
              achievement.category_id = a[:categoryId] unless achievement.category_id = a[:categoryId]
              # TODO figure out how to deal with achievements like "250 emblems"
              # where it's 1 achievement id with multiple point values
              achievement.points ||= nil # a[:points] 
              achievement.icon = a[:icon] unless achievement.icon == a[:icon]
              achievement.save if achievement.changed? # this should only save if any columns were changed
              # update completed status for toon here (create toon_achievement)
              if a[:dateCompleted] && achievement.toon_achievements.select{|ta|ta[:toon_id]==toon[:id]}.first.nil?
                achievement.toon_achievements.create(:toon_id => toon.id, :completed_at => a[:dateCompleted])
              end
              # loop through criteria elements and add links to child achievements
              (a/:criteria).each do |criteria|
                ca = all_achievements.select{|aa|aa.title==criteria[:name]}.first
                # ca = Achievement.find_by_title(criteria[:name], :include => [:criterias])
                if ca
                  achievement.criterias.select{|c|c[:id]==ca[:id]}.first || achievement.criterias << ca
                end
              end
            end
          rescue
            log "Failed to retrieve/process achievements for #{toon.name}"
          end
        end
      end
    end

    task :update_item_data, :needs => :environment do
      item_count = Item.count
      Item.all.each_with_index do |item, i|
        item.update_from_armory!
        puts "[#{'%05d' % i}/#{'%05d' % item_count}] [id:#{item[:id]}] [name:\"#{item[:name]}\"]"
        sleep 3
      end
    end
  end
end
