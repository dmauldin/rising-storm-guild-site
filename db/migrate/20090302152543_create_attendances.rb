class CreateAttendances < ActiveRecord::Migration
  def self.up
    create_table :attendances do |t|
      t.integer :toon_id
      t.integer :raid_id
      t.boolean :sat
      t.datetime :joined_at
      t.datetime :parted_at

      t.timestamps
    end
  end

  def self.down
    drop_table :attendances
  end
end
