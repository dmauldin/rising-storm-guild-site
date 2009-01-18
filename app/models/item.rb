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
  has_many :loots, :dependent => :destroy
  belongs_to :token_cost, :class_name => 'Item'
  
  def currency_for
    Item.all(:conditions => {:token_cost_id => self.id})
  end
  
  def update_from_armory
  end
end
