class AddColumnsToLoots < ActiveRecord::Migration
  def self.up
    add_column :loots, :status, :string
    Loot.all(:include => :toon).each do |loot|
      if loot.toon.name == "bank"
        status = "banked"
      elsif loot.toon.name == "disenchanted"
        status = "disenchanted"
      elsif loot.primary?
        status = "primary"
      else
        status = "secondary"
      end
      loot.update_attribute :status, status
    end
  end

  def self.down
    remove_column :loots, :status
  end
end
