# == Schema Information
# Schema version: 20081219192707
#
# Table name: toons
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  main_id    :integer
#  job_id     :integer
#  level      :integer
#  created_at :datetime
#  updated_at :datetime
#

class Toon < ActiveRecord::Base
  has_many :loots
  belongs_to :main, :class_name => "Toon"
  belongs_to :user
  has_many :professions
  belongs_to :job

  has_many :primary_loots, :class_name => 'Loot', :conditions => {:primary => true}
  has_many :secondary_loots, :class_name => 'Loot', :conditions => {:primary => false}
  
  def last_primary
    self.loots.primary.first(:order => "looted_at desc")
  end

  def after_create
    update_from_armory
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
