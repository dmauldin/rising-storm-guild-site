class AddPrimaryToLoots < ActiveRecord::Migration
  def self.up
    add_column :loots, :primary, :boolean, :default => true
  end

  def self.down
    remove_column :loots, :primary
  end
end
