class ToonSpec < ActiveRecord::Base
  belongs_to :toon
  belongs_to :spec

  validates_uniqueness_of :spec_id, :scope => :toon_id
  validates_uniqueness_of :status, :scope => :toon_id
  validates_inclusion_of :status, :in => ['main spec', 'off spec']
end
