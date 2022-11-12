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

ActiveRecord::Schema[7.0].define(version: 2022_11_12_162410) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "arrows", force: :cascade do |t|
    t.bigint "grave_id", null: false
    t.bigint "figure_id", null: false
    t.float "angle"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["figure_id"], name: "index_arrows_on_figure_id"
    t.index ["grave_id"], name: "index_arrows_on_grave_id"
  end

  create_table "corpses", force: :cascade do |t|
    t.bigint "grave_id", null: false
    t.bigint "figure_id", null: false
    t.float "angle"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["figure_id"], name: "index_corpses_on_figure_id"
    t.index ["grave_id"], name: "index_corpses_on_grave_id"
  end

  create_table "figures", force: :cascade do |t|
    t.bigint "page_id", null: false
    t.float "x1", null: false
    t.float "x2", null: false
    t.float "y1", null: false
    t.float "y2", null: false
    t.string "type_name", null: false
    t.string "tags", null: false, array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["page_id"], name: "index_figures_on_page_id"
  end

  create_table "goods", force: :cascade do |t|
    t.bigint "grave_id", null: false
    t.bigint "figure_id", null: false
    t.integer "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["figure_id"], name: "index_goods_on_figure_id"
    t.index ["grave_id"], name: "index_goods_on_grave_id"
  end

  create_table "graves", force: :cascade do |t|
    t.string "location"
    t.bigint "figure_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["figure_id"], name: "index_graves_on_figure_id"
  end

  create_table "images", force: :cascade do |t|
    t.binary "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "page_images", force: :cascade do |t|
    t.bigint "page_id", null: false
    t.bigint "image_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["image_id"], name: "index_page_images_on_image_id"
    t.index ["page_id"], name: "index_page_images_on_page_id"
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

  create_table "scales", force: :cascade do |t|
    t.bigint "figure_id", null: false
    t.bigint "grave_id", null: false
    t.float "meter_ratio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["figure_id"], name: "index_scales_on_figure_id"
    t.index ["grave_id"], name: "index_scales_on_grave_id"
  end

  create_table "skulls", force: :cascade do |t|
    t.bigint "corpse_id", null: false
    t.bigint "figure_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["corpse_id"], name: "index_skulls_on_corpse_id"
    t.index ["figure_id"], name: "index_skulls_on_figure_id"
  end

  add_foreign_key "arrows", "figures"
  add_foreign_key "arrows", "graves", column: "grave_id"
  add_foreign_key "corpses", "figures"
  add_foreign_key "corpses", "graves", column: "grave_id"
  add_foreign_key "figures", "pages", on_delete: :cascade
  add_foreign_key "goods", "figures"
  add_foreign_key "goods", "graves", column: "grave_id"
  add_foreign_key "graves", "figures"
  add_foreign_key "page_images", "images", on_delete: :cascade
  add_foreign_key "page_images", "pages", on_delete: :cascade
  add_foreign_key "pages", "images", on_delete: :cascade
  add_foreign_key "pages", "publications", on_delete: :cascade
  add_foreign_key "scales", "figures"
  add_foreign_key "scales", "graves", column: "grave_id"
  add_foreign_key "skulls", "corpses"
  add_foreign_key "skulls", "figures"
end
