class AddCostsToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :token_cost_id, :integer, :default => nil
    add_column :items, :cost, :integer, :default => nil
    add_column :items, :honor_cost, :integer, :default => nil
    add_index :items, :token_cost_id
  end

  def self.down
    remove_index :items, :token_cost_id
    remove_column :items, :token_cost_id
    remove_column :items, :cost
    remove_column :items, :honor_cost
  end
end
