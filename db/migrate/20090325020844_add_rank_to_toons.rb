class AddRankToToons < ActiveRecord::Migration
  def self.up
    add_column :toons, :rank, :integer
  end

  def self.down
    remove_column :toons, :rank
  end
end
