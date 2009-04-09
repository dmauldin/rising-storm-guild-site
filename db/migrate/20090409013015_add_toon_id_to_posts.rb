class AddToonIdToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :toon_id, :integer
  end

  def self.down
    remove_column :posts, :toon_id
  end
end
