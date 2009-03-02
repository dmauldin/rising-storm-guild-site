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

ActiveRecord::Schema.define(:version => 20090302152543) do

  create_table "attendances", :force => true do |t|
    t.integer  "toon_id"
    t.integer  "raid_id"
    t.boolean  "sat"
    t.datetime "joined_at"
    t.datetime "parted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "items", :force => true do |t|
    t.string   "name"
    t.integer  "wow_id"
    t.string   "icon"
    t.integer  "level"
    t.integer  "quality"
    t.string   "item_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "token_cost_id"
    t.integer  "cost"
    t.integer  "honor_cost"
    t.string   "subclass_name"
    t.integer  "inventory_type"
    t.integer  "required_level"
    t.text     "armory_item_xml"
    t.text     "armory_tooltip_xml"
    t.datetime "armory_updated_at"
  end

  add_index "items", ["token_cost_id"], :name => "index_items_on_token_cost_id"

  create_table "jobs", :force => true do |t|
    t.string   "name"
    t.string   "color"
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

  create_table "professions", :force => true do |t|
    t.integer  "toon_id"
    t.integer  "skill_id"
    t.integer  "level"
    t.integer  "maxlevel"
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

  create_table "skills", :force => true do |t|
    t.string   "name"
    t.integer  "maxlevel"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "toons", :force => true do |t|
    t.string   "name"
    t.integer  "main_id"
    t.integer  "job_id"
    t.integer  "level"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "gender"
    t.string   "race"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "encrypted_password", :limit => 128
    t.string   "salt",               :limit => 128
    t.string   "token",              :limit => 128
    t.datetime "token_expires_at"
    t.boolean  "email_confirmed",                   :default => false, :null => false
    t.boolean  "admin",                             :default => false, :null => false
  end

  add_index "users", ["admin"], :name => "index_users_on_admin"
  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["id", "token"], :name => "index_users_on_id_and_token"
  add_index "users", ["token"], :name => "index_users_on_token"

  create_table "zones", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
