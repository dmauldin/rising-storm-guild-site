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
end
