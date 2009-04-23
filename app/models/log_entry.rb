# == Schema Information
# Schema version: 20090409013015
#
# Table name: log_entries
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)
#  item_id    :integer(4)
#  item_type  :string(255)
#  action     :string(255)
#  comment    :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class LogEntry < ActiveRecord::Base
end
