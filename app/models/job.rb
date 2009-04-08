# == Schema Information
# Schema version: 20090302152543
#
# Table name: jobs
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  color      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Job < ActiveRecord::Base
  JOBS = ['Warrior', 'Paladin', 'Hunter', 'Rogue', 'Priest', 'Death Knight',
          'Shaman', 'Mage', 'Warlock', nil, 'Druid']
  JOB_COLORS = ['#C79C6E', '#F58CBA', '#ABD473', '#FFF569', '#FFFFFF',
                '#C41F3B', '#2459FF', '#69CCF0', '#9482C9', nil, '#FF7D0A']
end
