class AddViewCountToTopics < ActiveRecord::Migration
  def self.up
    add_column :topics, :view_count, :integer, :null => false, :default => 0
  end

  def self.down
    drop_column :topics, :view_count
  end
end
