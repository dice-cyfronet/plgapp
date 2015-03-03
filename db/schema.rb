# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150227100130) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.integer  "activity_type", default: 0
    t.datetime "created_at",                null: false
    t.integer  "app_id",                    null: false
    t.integer  "author_id",                 null: false
  end

  add_index "activities", ["app_id"], name: "index_activities_on_app_id", using: :btree
  add_index "activities", ["author_id"], name: "index_activities_on_author_id", using: :btree

  create_table "app_members", force: :cascade do |t|
    t.integer  "app_id",     null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "app_members", ["app_id", "user_id"], name: "index_app_members_on_app_id_and_user_id", unique: true, using: :btree

  create_table "apps", force: :cascade do |t|
    t.string   "name",       default: "", null: false
    t.string   "subdomain",               null: false
    t.text     "login_text"
    t.string   "content"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "apps", ["subdomain"], name: "index_apps_on_subdomain", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",              default: "", null: false
    t.integer  "sign_in_count",      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "login",                           null: false
    t.string   "name",               default: "", null: false
    t.text     "proxy"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["login"], name: "index_users_on_login", unique: true, using: :btree

  add_foreign_key "activities", "apps"
  add_foreign_key "activities", "users", column: "author_id"
  add_foreign_key "app_members", "apps"
  add_foreign_key "app_members", "users"
end
