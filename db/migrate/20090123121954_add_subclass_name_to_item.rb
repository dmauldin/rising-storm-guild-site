class AddSubclassNameToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :subclass_name, :string
    add_column :items, :inventory_type, :integer
  end

  def self.down
    remove_column :items, :subclass_name
    remove_column :items, :inventory_type
  end
end
