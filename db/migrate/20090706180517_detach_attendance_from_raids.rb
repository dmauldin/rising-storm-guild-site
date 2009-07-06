class DetachAttendanceFromRaids < ActiveRecord::Migration
  def self.up
    add_column :raids, :official, :boolean, :default => true
  end

  def self.down
    remove_column :raids, :official
  end
end
