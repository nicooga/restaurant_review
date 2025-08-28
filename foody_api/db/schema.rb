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

ActiveRecord::Schema[8.0].define(version: 2025_08_28_144024) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "meal_plan_members", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "meal_plan_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meal_plan_id"], name: "index_meal_plan_members_on_meal_plan_id"
    t.index ["user_id"], name: "index_meal_plan_members_on_user_id"
  end

  create_table "meal_plans", force: :cascade do |t|
    t.json "proposed_restaurants"
    t.json "proposed_time_slots"
    t.json "poll"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "meal_preferences", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.json "cusine_preferences"
    t.decimal "preferred_location_lat"
    t.decimal "preferred_location_lng"
    t.json "availability_schedule"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_meal_preferences_on_user_id"
  end

  create_table "restaurants", force: :cascade do |t|
    t.string "name", null: false
    t.integer "cuisine_type", null: false
    t.integer "price_range", null: false
    t.decimal "calculated_rating", precision: 3, scale: 2, default: "0.0"
    t.string "address"
    t.text "description"
    t.string "phone"
    t.string "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calculated_rating"], name: "index_restaurants_on_calculated_rating"
    t.index ["cuisine_type"], name: "index_restaurants_on_cuisine_type"
    t.index ["name"], name: "index_restaurants_on_name"
    t.index ["price_range"], name: "index_restaurants_on_price_range"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "rating", null: false
    t.text "comment", null: false
    t.bigint "user_id", null: false
    t.bigint "restaurant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rating"], name: "index_reviews_on_rating"
    t.index ["restaurant_id", "created_at"], name: "index_reviews_on_restaurant_id_and_created_at"
    t.index ["restaurant_id", "user_id"], name: "index_reviews_on_restaurant_id_and_user_id"
    t.index ["restaurant_id"], name: "index_reviews_on_restaurant_id"
    t.index ["user_id", "created_at"], name: "index_reviews_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "availability_schedule"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "meal_plan_members", "meal_plans"
  add_foreign_key "meal_plan_members", "users"
  add_foreign_key "meal_preferences", "users"
  add_foreign_key "reviews", "restaurants"
  add_foreign_key "reviews", "users"
  add_foreign_key "sessions", "users"
end
