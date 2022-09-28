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

ActiveRecord::Schema[7.0].define(version: 2022_09_28_144228) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "figures", force: :cascade do |t|
    t.bigint "page_id", null: false
    t.bigint "image_id", null: false
    t.jsonb "shape"
    t.string "tags", array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["image_id"], name: "index_figures_on_image_id"
    t.index ["page_id"], name: "index_figures_on_page_id"
  end

  create_table "images", force: :cascade do |t|
    t.binary "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pages", force: :cascade do |t|
    t.bigint "publication_id", null: false
    t.integer "number"
    t.bigint "image_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["image_id"], name: "index_pages_on_image_id"
    t.index ["publication_id"], name: "index_pages_on_publication_id"
  end

  create_table "publications", force: :cascade do |t|
    t.binary "pdf"
    t.string "author"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "figures", "images", on_delete: :cascade
  add_foreign_key "figures", "pages", on_delete: :cascade
  add_foreign_key "pages", "images", on_delete: :cascade
  add_foreign_key "pages", "publications", on_delete: :cascade
end
