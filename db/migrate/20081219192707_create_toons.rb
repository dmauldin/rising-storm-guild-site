class CreateToons < ActiveRecord::Migration
  def self.up
    create_table :toons do |t|
      t.string :name
      t.integer :main_id
      t.integer :job_id
      t.integer :level
      t.timestamps
    end
  end

  def self.down
    drop_table :toons
  end
end
