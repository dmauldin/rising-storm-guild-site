class AddUserIdToToons < ActiveRecord::Migration
  def self.up
    add_column :toons, :user_id, :integer
    add_index :toons, :user_id
  end

  def self.down
    remove_index :toons, :user_id
    remove_column :toons, :user_id
  end
end
