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

ActiveRecord::Schema[7.0].define(version: 2023_01_20_205619) do
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
    t.index ["skeleton_id"], name: "index_anthropologies_on_skeleton_id"
  end

  create_table "arrows", force: :cascade do |t|
    t.bigint "grave_id", null: false
    t.integer "figure_id", null: false
    t.float "angle"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["figure_id"], name: "index_arrows_on_figure_id"
    t.index ["grave_id"], name: "index_arrows_on_grave_id"
  end

  create_table "bones", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "c14_dates", force: :cascade do |t|
    t.integer "c14_type", null: false
    t.string "lab_id"
    t.integer "age_bp", null: false
    t.integer "interval", null: false
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

  create_table "cross_section_arrows", force: :cascade do |t|
    t.bigint "figure_id", null: false
    t.bigint "grave_id", null: false
    t.integer "length"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["figure_id"], name: "index_cross_section_arrows_on_figure_id"
    t.index ["grave_id"], name: "index_cross_section_arrows_on_grave_id"
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
    t.string "type_name", null: false
    t.string "tags", null: false, array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["page_id"], name: "index_figures_on_page_id"
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

  create_table "goods", force: :cascade do |t|
    t.bigint "grave_id", null: false
    t.integer "figure_id", null: false
    t.integer "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["figure_id"], name: "index_goods_on_figure_id"
    t.index ["grave_id"], name: "index_goods_on_grave_id"
  end

  create_table "grave_cross_sections", force: :cascade do |t|
    t.bigint "grave_id", null: false
    t.integer "figure_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["figure_id"], name: "index_grave_cross_sections_on_figure_id"
    t.index ["grave_id"], name: "index_grave_cross_sections_on_grave_id"
  end

  create_table "graves", force: :cascade do |t|
    t.string "location"
    t.integer "figure_id", null: false
    t.integer "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "arc_length"
    t.float "area"
    t.bigint "kurgan_id"
    t.index ["figure_id"], name: "index_graves_on_figure_id"
    t.index ["kurgan_id"], name: "index_graves_on_kurgan_id"
    t.index ["site_id"], name: "index_graves_on_site_id"
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
  end

  create_table "scales", force: :cascade do |t|
    t.integer "figure_id", null: false
    t.bigint "grave_id", null: false
    t.float "meter_ratio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["figure_id"], name: "index_scales_on_figure_id"
    t.index ["grave_id"], name: "index_scales_on_grave_id"
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
    t.bigint "grave_id", null: false
    t.integer "figure_id", null: false
    t.float "angle"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "skeleton_id"
    t.index ["figure_id"], name: "index_skeletons_on_figure_id"
    t.index ["grave_id"], name: "index_skeletons_on_grave_id"
  end

  create_table "skulls", force: :cascade do |t|
    t.bigint "skeleton_id", null: false
    t.integer "figure_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["figure_id"], name: "index_skulls_on_figure_id"
    t.index ["skeleton_id"], name: "index_skulls_on_skeleton_id"
  end

  create_table "spines", force: :cascade do |t|
    t.bigint "grave_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "figure_id"
    t.bigint "skeleton_id"
    t.index ["figure_id"], name: "index_spines_on_figure_id"
    t.index ["grave_id"], name: "index_spines_on_grave_id"
    t.index ["skeleton_id"], name: "index_spines_on_skeleton_id"
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

  create_table "y_haplogroups", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "arrows", "figures"
  add_foreign_key "arrows", "graves"
  add_foreign_key "cross_section_arrows", "figures"
  add_foreign_key "cross_section_arrows", "graves"
  add_foreign_key "figures", "pages", on_delete: :cascade
  add_foreign_key "genetics", "skeletons"
  add_foreign_key "goods", "figures"
  add_foreign_key "goods", "graves"
  add_foreign_key "grave_cross_sections", "figures"
  add_foreign_key "grave_cross_sections", "graves"
  add_foreign_key "graves", "figures"
  add_foreign_key "pages", "images", on_delete: :cascade
  add_foreign_key "pages", "publications", on_delete: :cascade
  add_foreign_key "scales", "figures"
  add_foreign_key "scales", "graves"
  add_foreign_key "skeletons", "figures"
  add_foreign_key "skeletons", "graves"
  add_foreign_key "skulls", "figures"
  add_foreign_key "skulls", "skeletons"
  add_foreign_key "spines", "figures"
  add_foreign_key "spines", "graves"
  add_foreign_key "stable_isotopes", "skeletons"
end
