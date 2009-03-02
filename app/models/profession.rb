# == Schema Information
# Schema version: 20090302152543
#
# Table name: professions
#
#  id         :integer(4)      not null, primary key
#  toon_id    :integer(4)
#  skill_id   :integer(4)
#  level      :integer(4)
#  maxlevel   :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class Profession < ActiveRecord::Base
end
