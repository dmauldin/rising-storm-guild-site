class AddIndexForAttendances < ActiveRecord::Migration
  def self.up
    add_index :attendances, :raid_id
  end

  def self.down
    remove_index :attendances, :raid_id
  end
end
