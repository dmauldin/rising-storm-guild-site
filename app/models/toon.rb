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

  has_many :primary_loots, :class_name => 'Loot', :conditions => {:primary => true}
  has_many :secondary_loots, :class_name => 'Loot', :conditions => {:primary => false}
  
  def after_create
    update_from_armory
    self.save
  end
  
  def update_from_armory
    unless ['bank', 'disenchant'].include?(self.name)
      agent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.7.6) Gecko/20050317 Firefox/1.0.2"
      accept = "text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8 "
      charset = "ISO-8859-1,utf-8;q=0.7,*;q=0.7"
      # get additional information from armory
      armory_character_url = "http://www.wowarmory.com/character-sheet.xml?r=#{REALM_NAME}&n=#{self.name}"
      data = open(armory_character_url, "User-Agent" => agent, "Accept" => accept, "Accept-Charset" => charset)
      if data
        doc = Hpricot.XML(data) 
        unless doc.nil?
          character = doc.search("character")
          self.level = character.attr("level")
          self.job_id = character.attr("classId")
          self.gender = character.attr("gender")
          self.race = character.attr("race")
        end
      end
    end
  end

end
