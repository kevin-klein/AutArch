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

ActiveRecord::Schema[7.0].define(version: 2023_03_06_115210) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "anthropologies", force: :cascade do |t|
    t.integer "sex_morph"
    t.integer "sex_gen"
    t.integer "sex_consensus"
    t.string "age_as_reported"
    t.integer "age_class"
    t.float "height"
    t.string "pathologies_type"
    t.bigint "skeleton_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "species"
    t.index ["skeleton_id"], name: "index_anthropologies_on_skeleton_id"
  end

  create_table "bones", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "c14_dates", force: :cascade do |t|
    t.integer "c14_type", null: false
    t.string "lab_id"
    t.integer "age_bp"
    t.integer "interval"
    t.integer "material"
    t.float "calbc_1_sigma_max"
    t.float "calbc_1_sigma_min"
    t.float "calbc_2_sigma_max"
    t.float "calbc_2_sigma_min"
    t.string "date_note"
    t.integer "cal_method"
    t.string "ref_14c", array: true
    t.bigint "chronology_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "bone_id"
    t.index ["bone_id"], name: "index_c14_dates_on_bone_id"
    t.index ["chronology_id"], name: "index_c14_dates_on_chronology_id"
  end

  create_table "chronologies", force: :cascade do |t|
    t.integer "context_from"
    t.integer "context_to"
    t.bigint "skeleton_id"
    t.bigint "grave_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "period_id"
    t.index ["grave_id"], name: "index_chronologies_on_grave_id"
    t.index ["period_id"], name: "index_chronologies_on_period_id"
    t.index ["skeleton_id"], name: "index_chronologies_on_skeleton_id"
  end

  create_table "cultures", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "figures", force: :cascade do |t|
    t.bigint "page_id", null: false
    t.integer "x1", null: false
    t.integer "x2", null: false
    t.integer "y1", null: false
    t.integer "y2", null: false
    t.string "type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "area"
    t.float "perimeter"
    t.float "meter_ratio"
    t.float "angle"
    t.integer "parent_id"
    t.string "identifier"
    t.float "width"
    t.float "height"
    t.string "text"
    t.bigint "site_id"
    t.boolean "verified", default: false, null: false
    t.boolean "disturbed", default: false, null: false
    t.point "contour", default: [], null: false, array: true
    t.index ["page_id"], name: "index_figures_on_page_id"
    t.index ["site_id"], name: "index_figures_on_site_id"
  end

  create_table "genetics", force: :cascade do |t|
    t.integer "data_type"
    t.float "endo_content"
    t.string "ref_gen"
    t.bigint "skeleton_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "mt_haplogroup_id"
    t.bigint "y_haplogroup_id"
    t.bigint "bone_id"
    t.index ["bone_id"], name: "index_genetics_on_bone_id"
    t.index ["mt_haplogroup_id"], name: "index_genetics_on_mt_haplogroup_id"
    t.index ["skeleton_id"], name: "index_genetics_on_skeleton_id"
    t.index ["y_haplogroup_id"], name: "index_genetics_on_y_haplogroup_id"
  end

  create_table "images", force: :cascade do |t|
    t.binary "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "width"
    t.integer "height"
  end

  create_table "kurgans", force: :cascade do |t|
    t.integer "width"
    t.integer "height"
    t.string "name", null: false
    t.bigint "publication_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["publication_id"], name: "index_kurgans_on_publication_id"
  end

  create_table "mt_haplogroups", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "page_texts", force: :cascade do |t|
    t.bigint "page_id", null: false
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["page_id"], name: "index_page_texts_on_page_id"
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

  create_table "periods", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "publications", force: :cascade do |t|
    t.binary "pdf"
    t.string "author"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "year"
  end

  create_table "sites", force: :cascade do |t|
    t.float "lat"
    t.float "lon"
    t.string "name"
    t.string "locality"
    t.integer "country_code"
    t.string "site_code"
  end

  create_table "skeletons", force: :cascade do |t|
    t.integer "figure_id", null: false
    t.float "angle"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "skeleton_id"
    t.integer "funerary_practice"
    t.integer "inhumation_type"
    t.integer "anatonimcal_connection"
    t.integer "body_position"
    t.integer "crouching_type"
    t.string "other"
    t.float "head_facing"
    t.integer "ochre"
    t.integer "ochre_position"
    t.bigint "skeleton_figure_id"
    t.bigint "site_id"
    t.index ["figure_id"], name: "index_skeletons_on_figure_id"
    t.index ["site_id"], name: "index_skeletons_on_site_id"
    t.index ["skeleton_figure_id"], name: "index_skeletons_on_skeleton_figure_id"
  end

  create_table "stable_isotopes", force: :cascade do |t|
    t.bigint "skeleton_id", null: false
    t.string "iso_id"
    t.float "iso_value"
    t.string "ref_iso"
    t.integer "isotope"
    t.integer "baseline"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "bone_id"
    t.index ["bone_id"], name: "index_stable_isotopes_on_bone_id"
    t.index ["skeleton_id"], name: "index_stable_isotopes_on_skeleton_id"
  end

  create_table "taxonomies", force: :cascade do |t|
    t.bigint "skeleton_id"
    t.string "culture_note"
    t.string "culture_reference"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "culture_id"
    t.index ["culture_id"], name: "index_taxonomies_on_culture_id"
    t.index ["skeleton_id"], name: "index_taxonomies_on_skeleton_id"
  end

  create_table "text_items", force: :cascade do |t|
    t.bigint "page_id", null: false
    t.string "text"
    t.integer "x1"
    t.integer "x2"
    t.integer "y1"
    t.integer "y2"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["page_id"], name: "index_text_items_on_page_id"
  end

  create_table "y_haplogroups", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "figures", "pages", on_delete: :cascade
  add_foreign_key "genetics", "skeletons"
  add_foreign_key "page_texts", "pages"
  add_foreign_key "pages", "images", on_delete: :cascade
  add_foreign_key "pages", "publications", on_delete: :cascade
  add_foreign_key "skeletons", "figures"
  add_foreign_key "stable_isotopes", "skeletons"
  add_foreign_key "text_items", "pages"
end
