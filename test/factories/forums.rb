Factory.sequence :forum_title do |n|
  "forum title #{n}"
end

Factory.define :forum do |forum|
  forum.title { Factory.next(:forum_title) }
end
