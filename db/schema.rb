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

ActiveRecord::Schema.define(version: 20180507125747) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_git_hubs", force: :cascade do |t|
    t.bigint "user_id"
    t.string "login"
    t.integer "owner_id"
    t.string "avatar_url"
    t.string "gravatar_id"
    t.string "email"
    t.string "url"
    t.string "html_url"
    t.string "user_type"
    t.string "name"
    t.string "nickname"
    t.string "company"
    t.string "location"
    t.integer "public_repos"
    t.integer "public_gists"
    t.datetime "user_created_at"
    t.datetime "user_updated_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_users_git_hubs_on_deleted_at"
    t.index ["user_id"], name: "index_users_git_hubs_on_user_id"
  end

  add_foreign_key "users_git_hubs", "users"
end
