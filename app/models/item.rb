# == Schema Information
# Schema version: 20081219192707
#
# Table name: items
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  wow_id     :integer
#  icon       :string(255)
#  level      :integer
#  quality    :integer
#  item_type  :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Item < ActiveRecord::Base
  has_many :loots
  
  def to_param
    wow_id.to_s
  end
end
