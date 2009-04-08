Factory.sequence :toon_name do |n|
  "Toonname#{n}"
end

Factory.define :toon do |toon|
  toon.name { Factory.next(:toon_name) }
  toon.level 80
  toon.job Factory(:job)
end
