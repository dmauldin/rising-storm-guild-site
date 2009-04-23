# == Schema Information
# Schema version: 20090409013015
#
# Table name: toon_specs
#
#  id         :integer(4)      not null, primary key
#  toon_id    :integer(4)      not null
#  spec_id    :integer(4)      not null
#  main       :boolean(1)      not null
#  created_at :datetime
#  updated_at :datetime
#

class ToonSpec < ActiveRecord::Base
  belongs_to :toon
  belongs_to :spec

  validates_uniqueness_of :spec_id, :scope => :toon_id
  validates_uniqueness_of :status, :scope => :toon_id
  validates_inclusion_of :status, :in => ['main spec', 'off spec']
end
