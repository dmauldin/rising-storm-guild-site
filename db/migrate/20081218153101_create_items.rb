class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.string :name
      t.integer :wow_id
      t.string :icon
      t.integer :level
      t.integer :quality
      t.string :item_type

      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end
