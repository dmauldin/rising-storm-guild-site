# Factory(:user, :email => "John.Doe@example.com")

Factory.sequence :achievement_title do |n|
  "Achievement Title #{n}"
end

Factory.define :achievement do |achievement|
  achievement.title { Factory.next :achievement_title }
end
