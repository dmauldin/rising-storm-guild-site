class CreateRaids < ActiveRecord::Migration
  def self.up
    create_table :raids do |t|
      t.datetime :start_at
      t.datetime :end_at
      t.integer :zone_id
      t.string :note

      t.timestamps
    end
  end

  def self.down
    drop_table :raids
  end
end
