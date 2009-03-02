class Attendance < ActiveRecord::Base
  belongs_to :toon
  belongs_to :raid
end
