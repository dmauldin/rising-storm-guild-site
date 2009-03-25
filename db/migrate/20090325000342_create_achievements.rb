class CreateAchievements < ActiveRecord::Migration
  def self.up
    create_table :achievements do |t|
      t.string :title, :null => false
      t.string :description
      t.integer :category_id
      t.string :icon
      t.integer :points

      t.timestamps
    end
  end

  def self.down
    drop_table :achievements
  end
end
