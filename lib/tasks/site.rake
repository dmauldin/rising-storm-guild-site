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
end

