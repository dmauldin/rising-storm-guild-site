class CreateForums < ActiveRecord::Migration
  def self.up
    create_table :forums do |t|
      t.string :title
      t.text :description
      t.integer :parent_id
      t.boolean :allow_topics

      t.timestamps
    end
  end

  def self.down
    drop_table :forums
  end
end
