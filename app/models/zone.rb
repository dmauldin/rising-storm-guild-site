# == Schema Information
# Schema version: 20090302152543
#
# Table name: zones
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Zone < ActiveRecord::Base
end
