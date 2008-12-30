# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20081219192707) do

  create_table "items", :force => true do |t|
    t.string   "name"
    t.integer  "wow_id"
    t.string   "icon"
    t.integer  "level"
    t.integer  "quality"
    t.string   "item_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "loots", :force => true do |t|
    t.integer  "raid_id"
    t.integer  "toon_id"
    t.integer  "mob_id"
    t.integer  "item_id"
    t.datetime "looted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "primary",    :default => true
  end

  create_table "mobs", :force => true do |t|
    t.string   "name"
    t.integer  "zone_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "raids", :force => true do |t|
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "zone_id"
    t.string   "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "key"
  end

  create_table "toons", :force => true do |t|
    t.string   "name"
    t.integer  "main_id"
    t.integer  "job_id"
    t.integer  "level"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "zones", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
