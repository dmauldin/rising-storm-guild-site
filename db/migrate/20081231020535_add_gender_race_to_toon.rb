class AddGenderRaceToToon < ActiveRecord::Migration
  def self.up
    add_column :toons, :gender, :string
    add_column :toons, :race, :string
  end

  def self.down
    remove_column :toons, :race
    remove_column :toons, :gender
  end
end
