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

ActiveRecord::Schema[8.1].define(version: 2026_04_11_020003) do
  create_table "fertilizations", force: :cascade do |t|
    t.decimal "amount", precision: 8, scale: 2
    t.date "applied_on", null: false
    t.datetime "created_at", null: false
    t.string "fertilizer_type", null: false
    t.integer "plant_id", null: false
    t.string "unit"
    t.datetime "updated_at", null: false
    t.index ["plant_id"], name: "index_fertilizations_on_plant_id"
  end

  create_table "harvests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "harvested_on", null: false
    t.integer "plant_id", null: false
    t.integer "quantity"
    t.string "unit"
    t.datetime "updated_at", null: false
    t.decimal "weight_grams", precision: 8, scale: 2
    t.index ["plant_id"], name: "index_harvests_on_plant_id"
  end

  create_table "plants", force: :cascade do |t|
    t.string "container_size"
    t.datetime "created_at", null: false
    t.integer "days_to_maturity"
    t.string "grow_medium", null: false
    t.string "location"
    t.string "name", null: false
    t.date "planted_on", null: false
    t.integer "seed_id"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["seed_id"], name: "index_plants_on_seed_id"
    t.index ["user_id"], name: "index_plants_on_user_id"
  end

  create_table "seeds", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "germination_days"
    t.string "name", null: false
    t.date "started_at"
    t.date "transplanted_at"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_seeds_on_user_id"
  end

  create_table "users", force: :cascade do |t|
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

  add_foreign_key "fertilizations", "plants"
  add_foreign_key "harvests", "plants"
  add_foreign_key "plants", "seeds"
  add_foreign_key "plants", "users"
  add_foreign_key "seeds", "users"
end
