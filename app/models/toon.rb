# == Schema Information
# Schema version: 20090302152543
#
# Table name: toons
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  main_id    :integer(4)
#  job_id     :integer(4)
#  level      :integer(4)
#  created_at :datetime
#  updated_at :datetime
#  gender     :string(255)
#  race       :string(255)
#

class Toon < ActiveRecord::Base
  has_many :loots
  belongs_to :main, :class_name => "Toon"
  belongs_to :user
  has_many :professions
  belongs_to :job
  has_many :attendances
  has_many :raids, :through => :attendances

  has_many :toon_achievements
  has_many :achievements, :through => :toon_achievements

  has_many :posts

  has_many :primary_loots, :class_name => 'Loot', :conditions => {:status => "primary"}
  has_many :secondary_loots, :class_name => 'Loot', :conditions => {:status => "secondary"}
  
  has_many :toon_specs
  has_many :specs, :through => :toon_specs

  # 0:GM, 1:Officer, 2:Organizer, 3:Raider, 4:Trial
  named_scope :raiders, :conditions => {:rank => 0..4}

  def last_primary
    self.loots.primary.first(:order => "looted_at desc")
  end

  # def after_create
  #   update_from_armory
  #   self.save
  # end
  # 
  # def update_from_armory
  #   wowr = Wowr::API.new(WOWR_DEFAULTS)
  #   begin
  #     toon = wowr.get_character(self.name)
  #     if toon
  #       self.level = toon.level
  #       self.job_id = toon.klass_id
  #       self.gender = toon.gender
  #       self.race = toon.race
  #       # add professions update here
  #     end
  #   rescue
  #     nil
  #   end
  # end
end
