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

ActiveRecord::Schema[8.1].define(version: 2024_05_15_120002) do
  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "equipment", force: :cascade do |t|
    t.integer "category_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "serial_number", null: false
    t.string "status", default: "available", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_equipment_on_category_id"
    t.index ["serial_number"], name: "index_equipment_on_serial_number", unique: true
  end

  create_table "maintenance_records", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.integer "equipment_id", null: false
    t.datetime "performed_at", null: false
    t.datetime "updated_at", null: false
    t.index ["equipment_id", "performed_at"], name: "index_maintenance_records_on_equipment_id_and_performed_at"
    t.index ["equipment_id"], name: "index_maintenance_records_on_equipment_id"
  end

  add_foreign_key "equipment", "categories"
  add_foreign_key "maintenance_records", "equipment"
end
