class CreateLogEntries < ActiveRecord::Migration
  def self.up
    create_table :log_entries do |t|
      t.integer :user_id
      t.integer :item_id  # poly model id 
      t.string :item_type # poly model class name ("User")
      t.string :action    # "deleted"
      t.string :comment   # "The user requested their information be deleted"
      t.timestamps
    end
  end

  def self.down
    drop_table :log_entries
  end
end
