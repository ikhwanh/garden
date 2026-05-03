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

ActiveRecord::Schema[8.1].define(version: 2026_05_03_065221) do
  create_table "cashflow_entries", force: :cascade do |t|
    t.bigint "amount"
    t.string "category"
    t.string "cost_type"
    t.datetime "created_at", null: false
    t.string "description"
    t.string "entry_type"
    t.date "occurred_on"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_cashflow_entries_on_user_id"
  end

  create_table "crops", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "expected_harvest_on"
    t.date "harvested_on"
    t.string "name", null: false
    t.text "note"
    t.integer "nursery_id"
    t.date "planted_on", null: false
    t.integer "preset_id"
    t.integer "quantity_final"
    t.integer "quantity_initial"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["nursery_id"], name: "index_crops_on_nursery_id"
    t.index ["user_id"], name: "index_crops_on_user_id"
  end

  create_table "nurseries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.text "note"
    t.integer "preset_id"
    t.integer "quantity_final"
    t.integer "quantity_initial"
    t.date "started_on"
    t.date "transplanted_on"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["preset_id"], name: "index_nurseries_on_preset_id"
    t.index ["user_id"], name: "index_nurseries_on_user_id"
  end

  create_table "presets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "days_max"
    t.integer "days_min"
    t.string "grow_type", null: false
    t.json "growing_conditions"
    t.string "local_name"
    t.string "name", null: false
    t.json "preset_data", default: {}, null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_presets_on_slug", unique: true
  end

  create_table "reminders", force: :cascade do |t|
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.integer "crop_id", null: false
    t.json "details", default: {}, null: false
    t.date "due_on", null: false
    t.datetime "notified_at"
    t.string "phase", null: false
    t.datetime "updated_at", null: false
    t.index ["crop_id", "due_on"], name: "index_reminders_on_crop_id_and_due_on"
    t.index ["crop_id"], name: "index_reminders_on_crop_id"
  end

  create_table "users", force: :cascade do |t|
    t.integer "altitude_masl"
    t.decimal "avg_humidity_pct"
    t.decimal "avg_temp_c"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "cashflow_entries", "users"
  add_foreign_key "crops", "nurseries"
  add_foreign_key "crops", "users"
  add_foreign_key "nurseries", "presets"
  add_foreign_key "nurseries", "users"
  add_foreign_key "reminders", "crops"
end
