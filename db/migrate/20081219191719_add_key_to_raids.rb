class AddKeyToRaids < ActiveRecord::Migration
  def self.up
    add_column :raids, :key, :string
  end

  def self.down
    remove_column :raids, :key
  end
end
