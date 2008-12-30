class CreateLoots < ActiveRecord::Migration
  def self.up
    create_table :loots do |t|
      t.integer :raid_id
      t.integer :toon_id
      t.integer :mob_id
      t.integer :item_id
      t.datetime :looted_at

      t.timestamps
    end
  end

  def self.down
    drop_table :loots
  end
end
