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

ActiveRecord::Schema.define(:version => 20090401012226) do

  create_table "achievement_criterias", :id => false, :force => true do |t|
    t.integer "achievement_id", :null => false
    t.integer "criteria_id",    :null => false
  end

  add_index "achievement_criterias", ["achievement_id", "criteria_id"], :name => "index_achievement_criterias_on_achievement_id_and_criteria_id"

  create_table "achievements", :force => true do |t|
    t.string   "title",       :null => false
    t.string   "description"
    t.integer  "category_id"
    t.string   "icon"
    t.integer  "points"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "attendances", :force => true do |t|
    t.integer  "toon_id"
    t.integer  "raid_id"
    t.boolean  "sat"
    t.datetime "joined_at"
    t.datetime "parted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "forums", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "parent_id"
    t.boolean  "allow_topics"
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
    t.string   "status"
  end

  create_table "mobs", :force => true do |t|
    t.string   "name"
    t.integer  "zone_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "posts", :force => true do |t|
    t.string   "title"
    t.integer  "topic_id"
    t.integer  "user_id"
    t.text     "body"
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

  create_table "specs", :force => true do |t|
    t.integer  "job_id",     :null => false
    t.string   "name",       :null => false
    t.string   "role",       :null => false
    t.string   "damage",     :null => false
    t.string   "distance",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "toon_achievements", :force => true do |t|
    t.integer  "toon_id",        :null => false
    t.integer  "achievement_id", :null => false
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "toon_achievements", ["toon_id", "achievement_id"], :name => "index_toon_achievements_on_toon_id_and_achievement_id"

  create_table "toon_specs", :force => true do |t|
    t.integer  "toon_id",    :null => false
    t.integer  "spec_id",    :null => false
    t.boolean  "main",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "toon_specs", ["main"], :name => "index_toon_specs_on_main"
  add_index "toon_specs", ["toon_id", "spec_id"], :name => "index_toon_specs_on_toon_id_and_spec_id"

  create_table "toons", :force => true do |t|
    t.string   "name"
    t.integer  "main_id"
    t.integer  "job_id"
    t.integer  "level"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "gender"
    t.string   "race"
    t.integer  "rank"
    t.boolean  "deleted",            :default => false
    t.boolean  "wants_achievements", :default => false
  end

  add_index "toons", ["rank"], :name => "index_toons_on_rank"
  add_index "toons", ["wants_achievements"], :name => "index_toons_on_wants_achievements"

  create_table "topics", :force => true do |t|
    t.string   "title"
    t.integer  "forum_id"
    t.boolean  "locked"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "encrypted_password", :limit => 128
    t.string   "salt",               :limit => 128
    t.string   "token",              :limit => 128
    t.datetime "token_expires_at"
    t.boolean  "email_confirmed",                   :default => false, :null => false
    t.boolean  "admin",                             :default => false, :null => false
    t.boolean  "wants_achievements",                :default => false
  end

  add_index "users", ["admin"], :name => "index_users_on_admin"
  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["id", "token"], :name => "index_users_on_id_and_token"
  add_index "users", ["token"], :name => "index_users_on_token"
  add_index "users", ["wants_achievements"], :name => "index_users_on_wants_achievements"

  create_table "zones", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
