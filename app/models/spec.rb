# == Schema Information
# Schema version: 20090409013015
#
# Table name: specs
#
#  id         :integer(4)      not null, primary key
#  job_id     :integer(4)      not null
#  name       :string(255)     not null
#  role       :string(255)     not null
#  damage     :string(255)     not null
#  distance   :string(255)     not null
#  created_at :datetime
#  updated_at :datetime
#

class Spec < ActiveRecord::Base
  belongs_to :job
  has_many :toon_specs
  has_many :toons, :through => :toon_specs
end
