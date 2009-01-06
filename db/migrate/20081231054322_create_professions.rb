class CreateProfessions < ActiveRecord::Migration
  def self.up
    create_table :professions do |t|
      t.integer :toon_id
      t.integer :skill_id
      t.integer :level
      t.integer :maxlevel

      t.timestamps
    end
  end

  def self.down
    drop_table :professions
  end
end
