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

ActiveRecord::Schema[7.1].define(version: 2023_12_18_230322) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "budgets", force: :cascade do |t|
    t.bigint "family_id", null: false
    t.string "name", null: false
    t.string "icon", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.boolean "private", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "created_by"
    t.bigint "updated_by"
    t.index ["family_id"], name: "index_budgets_on_family_id"
  end

  create_table "expenses", force: :cascade do |t|
    t.bigint "budget_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.date "date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "created_by"
    t.bigint "updated_by"
    t.index ["budget_id"], name: "index_expenses_on_budget_id"
  end

  create_table "families", force: :cascade do |t|
    t.bigint "owner_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "created_by"
    t.bigint "updated_by"
    t.index ["owner_id"], name: "index_families_on_owner_id"
  end

  create_table "users", force: :cascade do |t|
    t.bigint "family_id"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "created_by"
    t.bigint "updated_by"
    t.index ["email"], name: "index_users_on_email"
    t.index ["family_id"], name: "index_users_on_family_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token"
  end

  add_foreign_key "budgets", "families"
  add_foreign_key "expenses", "budgets"
  add_foreign_key "families", "users", column: "owner_id"
end
