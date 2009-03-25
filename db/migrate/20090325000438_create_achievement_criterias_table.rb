class CreateAchievementCriteriasTable < ActiveRecord::Migration
  def self.up
    create_table :achievement_criterias, :id => false do |t|
      t.integer :achievement_id, :null => false
      t.integer :criteria_id, :null => false
    end
  end

  def self.down
    drop_table :achievement_criteras
  end
end
