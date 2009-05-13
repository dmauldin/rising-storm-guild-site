class ChangeRaidKeyToInstanceId < ActiveRecord::Migration
  def self.up
    rename_column :raids, :key, :instance_id
  end

  def self.down
    rename_column :raids, :instance_id, :key
  end
end
