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

ActiveRecord::Schema.define(version: 20180916080439) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", force: :cascade do |t|
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
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "changed_files", force: :cascade do |t|
    t.bigint "pull_id"
    t.bigint "commit_id"
    t.string "filename"
    t.integer "additions"
    t.integer "deletions"
    t.integer "difference"
    t.string "contents_url"
    t.text "patch"
    t.integer "event"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commit_id"], name: "index_changed_files_on_commit_id"
    t.index ["deleted_at"], name: "index_changed_files_on_deleted_at"
    t.index ["pull_id"], name: "index_changed_files_on_pull_id"
  end

  create_table "commits", force: :cascade do |t|
    t.bigint "reviewee_id"
    t.bigint "pull_id"
    t.string "sha"
    t.string "message"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_commits_on_deleted_at"
    t.index ["pull_id"], name: "index_commits_on_pull_id"
    t.index ["reviewee_id"], name: "index_commits_on_reviewee_id"
  end

  create_table "content_trees", force: :cascade do |t|
    t.bigint "parent_id"
    t.bigint "child_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["child_id"], name: "index_content_trees_on_child_id"
    t.index ["parent_id"], name: "index_content_trees_on_parent_id"
  end

  create_table "contents", force: :cascade do |t|
    t.bigint "reviewee_id"
    t.bigint "repo_id"
    t.integer "file_type"
    t.integer "status"
    t.string "size"
    t.string "name"
    t.string "path"
    t.text "content"
    t.string "html_url"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_contents_on_deleted_at"
    t.index ["repo_id"], name: "index_contents_on_repo_id"
    t.index ["reviewee_id"], name: "index_contents_on_reviewee_id"
  end

  create_table "issues", force: :cascade do |t|
    t.bigint "repo_id"
    t.bigint "reviewee_id"
    t.bigint "remote_id"
    t.integer "number"
    t.integer "status"
    t.integer "publish"
    t.string "title"
    t.text "body"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_issues_on_deleted_at"
    t.index ["repo_id"], name: "index_issues_on_repo_id"
    t.index ["reviewee_id"], name: "index_issues_on_reviewee_id"
  end

  create_table "pulls", force: :cascade do |t|
    t.bigint "reviewer_id"
    t.bigint "reviewee_id"
    t.bigint "repo_id"
    t.integer "remote_id"
    t.integer "number"
    t.string "title"
    t.string "body"
    t.integer "status"
    t.string "token"
    t.string "base_label"
    t.string "head_label"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_pulls_on_deleted_at"
    t.index ["repo_id"], name: "index_pulls_on_repo_id"
    t.index ["reviewee_id"], name: "index_pulls_on_reviewee_id"
    t.index ["reviewer_id"], name: "index_pulls_on_reviewer_id"
  end

  create_table "repos", force: :cascade do |t|
    t.bigint "reviewee_id"
    t.integer "remote_id"
    t.string "name"
    t.string "full_name"
    t.boolean "private"
    t.integer "status"
    t.bigint "installation_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_repos_on_deleted_at"
    t.index ["reviewee_id"], name: "index_repos_on_reviewee_id"
  end

  create_table "review_comments", force: :cascade do |t|
    t.bigint "reviewer_id"
    t.bigint "review_id"
    t.bigint "changed_file_id"
    t.text "body"
    t.string "path"
    t.integer "position"
    t.bigint "in_reply_to_id"
    t.bigint "remote_id"
    t.integer "status"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["changed_file_id"], name: "index_review_comments_on_changed_file_id"
    t.index ["deleted_at"], name: "index_review_comments_on_deleted_at"
    t.index ["review_id"], name: "index_review_comments_on_review_id"
    t.index ["reviewer_id"], name: "index_review_comments_on_reviewer_id"
  end

  create_table "reviewees", force: :cascade do |t|
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
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_reviewees_on_deleted_at"
    t.index ["email"], name: "index_reviewees_on_email", unique: true
    t.index ["reset_password_token"], name: "index_reviewees_on_reset_password_token", unique: true
  end

  create_table "reviewees_github_accounts", force: :cascade do |t|
    t.bigint "reviewee_id"
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
    t.datetime "reviewee_created_at"
    t.datetime "reviewee_updated_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_reviewees_github_accounts_on_deleted_at"
    t.index ["reviewee_id"], name: "index_reviewees_github_accounts_on_reviewee_id"
  end

  create_table "reviewers", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "status"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_reviewers_on_deleted_at"
    t.index ["email"], name: "index_reviewers_on_email", unique: true
    t.index ["reset_password_token"], name: "index_reviewers_on_reset_password_token", unique: true
  end

  create_table "reviewers_github_accounts", force: :cascade do |t|
    t.bigint "reviewer_id"
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
    t.datetime "reviewee_created_at"
    t.datetime "reviewee_updated_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_reviewers_github_accounts_on_deleted_at"
    t.index ["reviewer_id"], name: "index_reviewers_github_accounts_on_reviewer_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "pull_id"
    t.bigint "reviewer_id"
    t.bigint "remote_id"
    t.text "body"
    t.text "reason"
    t.integer "event"
    t.integer "working_hours"
    t.string "commit_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_reviews_on_deleted_at"
    t.index ["pull_id"], name: "index_reviews_on_pull_id"
    t.index ["reviewer_id"], name: "index_reviews_on_reviewer_id"
  end

  create_table "skillings", force: :cascade do |t|
    t.bigint "skill_id"
    t.integer "resource_id"
    t.string "resource_type"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_skillings_on_deleted_at"
    t.index ["resource_id", "resource_type"], name: "index_skillings_on_resource_id_and_resource_type"
    t.index ["skill_id"], name: "index_skillings_on_skill_id"
  end

  create_table "skills", force: :cascade do |t|
    t.string "name"
    t.integer "category"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_skills_on_deleted_at"
  end

  create_table "wikis", force: :cascade do |t|
    t.bigint "repo_id"
    t.bigint "reviewee_id"
    t.string "title"
    t.text "body"
    t.integer "status"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_wikis_on_deleted_at"
    t.index ["repo_id"], name: "index_wikis_on_repo_id"
    t.index ["reviewee_id"], name: "index_wikis_on_reviewee_id"
  end

  add_foreign_key "changed_files", "commits"
  add_foreign_key "changed_files", "pulls"
  add_foreign_key "commits", "pulls"
  add_foreign_key "commits", "reviewees"
  add_foreign_key "contents", "repos"
  add_foreign_key "contents", "reviewees"
  add_foreign_key "issues", "repos"
  add_foreign_key "issues", "reviewees"
  add_foreign_key "pulls", "repos"
  add_foreign_key "pulls", "reviewees"
  add_foreign_key "pulls", "reviewers"
  add_foreign_key "repos", "reviewees"
  add_foreign_key "review_comments", "changed_files"
  add_foreign_key "review_comments", "reviewers"
  add_foreign_key "review_comments", "reviews"
  add_foreign_key "reviewees_github_accounts", "reviewees"
  add_foreign_key "reviewers_github_accounts", "reviewers"
  add_foreign_key "reviews", "pulls"
  add_foreign_key "reviews", "reviewers"
  add_foreign_key "skillings", "skills"
  add_foreign_key "wikis", "repos"
  add_foreign_key "wikis", "reviewees"
end
