# == Schema Information
# Schema version: 20090409013015
#
# Table name: toons
#
#  id                 :integer(4)      not null, primary key
#  name               :string(255)
#  main_id            :integer(4)
#  job_id             :integer(4)
#  level              :integer(4)
#  created_at         :datetime
#  updated_at         :datetime
#  gender             :string(255)
#  race               :string(255)
#  rank               :integer(4)
#  deleted            :boolean(1)
#  wants_achievements :boolean(1)
#  user_id            :integer(4)
#

class Toon < ActiveRecord::Base
  has_many :loots
  belongs_to :main, :class_name => "Toon"
  belongs_to :user
  # profession = the toon's primary skill choices
  # skill = the actual skill the profession uses
  has_many :professions
  has_many :skills, :through => :professions
  
  belongs_to :job
  has_many :attendances, :dependent => :destroy
  has_many :raids, :through => :attendances

  has_many :toon_achievements
  has_many :achievements, :through => :toon_achievements

  has_many :posts

  has_many :primary_loots, :class_name => 'Loot', :conditions => {:status => "primary"}
  has_many :secondary_loots, :class_name => 'Loot', :conditions => {:status => "secondary"}
  
  has_many :toon_specs
  has_many :specs, :through => :toon_specs

  validates_presence_of :name
  validates_presence_of :job
  validates_inclusion_of :level, :in => 1..80
  
  # TODO: enable this validation for primary professions when they're in
  # def validate
  #   errors.add("Toons can only have 0, 1 or 2 professions") unless [0,1,2].include?(self.professions.length)
  # end
  
  # 0:GM, 1:GM Alt, 2:Organizer, 3:Raider, 4:Trial, 5:Alt, 6:Member
  named_scope :raiders, :conditions => ['rank in (?) and name not in (?)', RAIDER_RANKS, RAIDER_EXCLUSIONS], :include => :job

  def last_primary
    self.loots.primary.first(:order => "looted_at desc")
  end

  named_scope :sort_by_name, :order => 'name asc'
  
  # def after_create
  #   update_from_armory
  #   self.save
  # end

  # this gives the attendance based on days attended, not raids
  # there can be multiple raids and attendances per day
  # ex: toon.attendance_since(90.days.ago) returns "085%"
  def attendance_since(day)
    raids = Raid.all(:conditions => {:start_at_after => day, :official => true}, :group => 'date(start_at)')
    unless raids.empty?
      attendances = self.attendances.all(
        :group => 'date(raids.start_at)',
        :include => :raid,
        :conditions => {:raid => {:start_at => raids.collect(&:start_at)}})
      unless attendances.empty?
        "%03d%" % ((attendances.size.to_f / raids.size.to_f) * 100)
      end
    end
  end

  def update_from_armory!
    self.update_from_armory
    self.save
  end
  
  def update_from_armory
    wowr = Wowr::API.new(WOWR_DEFAULTS)
    begin
      toon = wowr.get_character(self.name)
      if toon
        self.level = toon.level
        self.job_id = toon.klass_id
        self.gender = toon.gender
        self.race = toon.race
        # add professions update here
      end
    rescue
      nil
    end
  end
end
