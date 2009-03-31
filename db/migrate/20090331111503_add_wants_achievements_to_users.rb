class AddWantsAchievementsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :wants_achievements, :boolean, :default => false
    add_index :users, :wants_achievements
  end

  def self.down
    remove_index :users, :wants_achievements
    remove_column :users, :wants_achievements
  end
end
