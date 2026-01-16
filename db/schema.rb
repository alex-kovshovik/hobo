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

ActiveRecord::Schema[8.1].define(version: 2025_01_19_214102) do
  create_table "budgets", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.bigint "created_by"
    t.integer "family_id", null: false
    t.string "icon", null: false
    t.string "name", null: false
    t.boolean "private", default: false, null: false
    t.datetime "updated_at", null: false
    t.bigint "updated_by"
    t.index ["family_id"], name: "index_budgets_on_family_id"
  end

  create_table "expenses", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.integer "budget_id", null: false
    t.datetime "created_at", null: false
    t.bigint "created_by"
    t.date "date", null: false
    t.datetime "updated_at", null: false
    t.bigint "updated_by"
    t.index ["budget_id"], name: "index_expenses_on_budget_id"
  end

  create_table "families", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "created_by"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.bigint "updated_by"
    t.index ["name"], name: "index_families_on_name"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: true, null: false
    t.datetime "created_at", null: false
    t.bigint "created_by"
    t.string "email_address", null: false
    t.integer "family_id"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.bigint "updated_by"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["family_id"], name: "index_users_on_family_id"
  end

  add_foreign_key "budgets", "families"
  add_foreign_key "expenses", "budgets"
  add_foreign_key "sessions", "users"
end
