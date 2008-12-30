class CreateMobs < ActiveRecord::Migration
  def self.up
    create_table :mobs do |t|
      t.string :name
      t.integer :zone_id

      t.timestamps
    end
  end

  def self.down
    drop_table :mobs
  end
end
