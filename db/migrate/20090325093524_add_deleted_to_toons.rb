class AddDeletedToToons < ActiveRecord::Migration
  def self.up
    add_column :toons, :deleted, :boolean, :default => false
  end

  def self.down
    remove_column :toons, :deleted
  end
end
