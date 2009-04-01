class AddWantsAchievementToToons < ActiveRecord::Migration
  def self.up
    add_column :toons, :wants_achievements, :boolean, :default => false
    add_index :toons, :wants_achievements
  end

  def self.down
    remove_index :toons, :wants_achievements
    remove_column :toons, :wants_achievements
  end
end
