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

  def after_create
    # get additional information from armory
    armory_character_url = "http://www.wowarmory.com/character-sheet.xml?r=#{REALM_NAME}&n=#{self.name}"
    character_xml = open_uri(armory_character_url)
  end

end
