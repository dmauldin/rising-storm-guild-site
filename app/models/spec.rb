class Spec < ActiveRecord::Base
  belongs_to :job
  has_many :toon_specs
  has_many :toons, :through => :toon_specs
end
