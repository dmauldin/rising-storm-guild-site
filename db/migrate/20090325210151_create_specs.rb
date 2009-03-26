class CreateSpecs < ActiveRecord::Migration
  def self.up
    create_table :specs do |t|
      t.integer :job_id, :null => false
      t.string :name, :null => false
      t.string :role, :null => false
      t.string :damage, :null => false
      t.string :distance, :null => false

      t.timestamps
    end
    create_table :toon_specs do |t|
      t.integer :toon_id, :null => false
      t.integer :spec_id, :null => false
      t.boolean    :main, :null => false
      t.timestamps
    end
    add_index :toon_specs, [:toon_id, :spec_id]
    add_index :toon_specs, :main
  end

  def self.down
    remove_index :toon_specs, :main
    remove_index :toon_specs, [:toon_id, :spec_id]
    drop_table :toon_specs
    drop_table :specs
  end
end
