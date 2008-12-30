# == Schema Information
# Schema version: 20081219192707
#
# Table name: raids
#
#  id         :integer         not null, primary key
#  start_at   :datetime
#  end_at     :datetime
#  zone_id    :integer
#  note       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  key        :string(255)
#

class Raid < ActiveRecord::Base
  has_many :loots
end
