class AddIndexesForAchievements < ActiveRecord::Migration
  def self.up
    add_index :toon_achievements, [:toon_id, :achievement_id]
    add_index :achievement_criterias, [:achievement_id, :criteria_id]
    add_index :toons, :rank
  end

  def self.down
    remove_index :toon_achievements, [:toon_id, :achievement_id]
    remove_index :achievement_criterias, [:achievement_id, :criteria_id]
    remove_index :toons, :rank
  end
end
