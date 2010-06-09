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

ActiveRecord::Schema.define(:version => 20100201164735) do

  create_table "cbac_generic_roles", :force => true do |t|
    t.string   "name"
    t.text     "remarks"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cbac_memberships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "generic_role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cbac_permissions", :force => true do |t|
    t.integer  "generic_role_id",  :default => 0
    t.string   "context_role"
    t.integer  "privilege_set_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cbac_privilege_set", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "news_items", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
