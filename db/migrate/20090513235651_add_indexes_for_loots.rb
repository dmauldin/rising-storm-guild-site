class AddIndexesForLoots < ActiveRecord::Migration
  def self.up
    add_index :items, :inventory_type
    add_index :items, :subclass_name
    add_index :toons, :name
    add_index :raids, :start_at
    add_index :loots, :raid_id
    add_index :loots, :toon_id
  end

  def self.down
    remove_index :items, :inventory_type
    remove_index :items, :subclass_name
    remove_index :toons, :name
    remove_index :raids, :start_at
    remove_index :loots, :raid_id
    remove_index :loots, :toon_id
  end
end
