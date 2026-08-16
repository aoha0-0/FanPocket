# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_08_16_060143) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "notification_deliveries", force: :cascade do |t|
    t.bigint "watchlist_id", null: false
    t.integer "channel", null: false
    t.integer "notification_type", null: false
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["watchlist_id", "channel", "notification_type"], name: "idx_on_watchlist_id_channel_notification_type_e10fc11b38", unique: true
    t.index ["watchlist_id"], name: "index_notification_deliveries_on_watchlist_id"
  end

  create_table "notification_settings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.boolean "email_three_days_before", default: true, null: false
    t.boolean "email_day_before", default: true, null: false
    t.boolean "email_deadline_same_day", default: true, null: false
    t.boolean "email_start_same_day", default: true, null: false
    t.boolean "line_start_ten_minutes_before", default: true, null: false
    t.boolean "line_deadline_three_hours_before", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notification_settings_on_user_id", unique: true
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "watchlist_id", null: false
    t.integer "notification_type", null: false
    t.string "title", null: false
    t.text "message", null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
    t.index ["watchlist_id"], name: "index_notifications_on_watchlist_id"
  end

  create_table "social_accounts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "provider", null: false
    t.string "uid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider", "uid"], name: "index_social_accounts_on_provider_and_uid", unique: true
    t.index ["user_id"], name: "index_social_accounts_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "name"], name: "index_tags_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_tags_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.datetime "onboarding_completed_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "watchlist_tags", force: :cascade do |t|
    t.bigint "watchlist_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id"], name: "index_watchlist_tags_on_tag_id"
    t.index ["watchlist_id", "tag_id"], name: "index_watchlist_tags_on_watchlist_id_and_tag_id", unique: true
    t.index ["watchlist_id"], name: "index_watchlist_tags_on_watchlist_id"
  end

  create_table "watchlists", force: :cascade do |t|
    t.string "title", null: false
    t.text "memo"
    t.string "url"
    t.datetime "start_at"
    t.datetime "end_at"
    t.boolean "is_done", default: false, null: false
    t.string "image"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "reception_type", default: 0, null: false
    t.string "reception_detail"
    t.index ["user_id"], name: "index_watchlists_on_user_id"
  end

  add_foreign_key "notification_deliveries", "watchlists"
  add_foreign_key "notification_settings", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "notifications", "watchlists"
  add_foreign_key "social_accounts", "users"
  add_foreign_key "tags", "users"
  add_foreign_key "watchlist_tags", "tags"
  add_foreign_key "watchlist_tags", "watchlists"
  add_foreign_key "watchlists", "users"
end
