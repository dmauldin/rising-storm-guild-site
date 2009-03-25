class CreateTopics < ActiveRecord::Migration
  def self.up
    create_table :topics do |t|
      t.string :title
      t.integer :forum_id
      t.boolean :locked
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :topics
  end
end
