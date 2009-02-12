class AddXmlToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :armory_item_xml, :text
    add_column :items, :armory_tooltip_xml, :text
    add_column :items, :armory_updated_at, :datetime
  end

  def self.down
    remove_column :items, :armory_item_xml
    remove_column :items, :armory_tooltip_xml
    remove_column :items, :armory_xml_updated_at
  end
end
