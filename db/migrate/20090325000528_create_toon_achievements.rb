class CreateToonAchievements < ActiveRecord::Migration
  def self.up
    create_table :toon_achievements do |t|
      t.integer :toon_id, :null => false
      t.integer :achievement_id, :null => false
      t.datetime :completed_at

      t.timestamps
    end
  end

  def self.down
    drop_table :toon_achievements
  end
end
