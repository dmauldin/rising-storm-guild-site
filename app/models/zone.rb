# == Schema Information
# Schema version: 20081219192707
#
# Table name: zones
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Zone < ActiveRecord::Base
end
