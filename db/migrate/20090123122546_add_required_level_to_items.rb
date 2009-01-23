class AddRequiredLevelToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :required_level, :integer
  end

  def self.down
    remove_column :items, :required_level
  end
end
