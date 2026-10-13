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

ActiveRecord::Schema[8.1].define(version: 2026_10_14_000000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "api_sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token_digest", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_api_sessions_on_expires_at"
    t.index ["token_digest"], name: "index_api_sessions_on_token_digest", unique: true
    t.index ["user_id"], name: "index_api_sessions_on_user_id"
  end

  create_table "game_entities", force: :cascade do |t|
    t.string "entity_type", null: false
    t.string "source_id", null: false
    t.string "slug", null: false
    t.boolean "publicly_available", default: false, null: false
    t.datetime "released_at"
    t.jsonb "source_data", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entity_type", "slug"], name: "index_game_entities_on_entity_type_and_slug", unique: true
    t.index ["entity_type", "source_id"], name: "index_game_entities_on_entity_type_and_source_id", unique: true
    t.index ["publicly_available", "released_at"], name: "index_game_entities_on_publicly_available_and_released_at"
  end

  create_table "page_blocks", force: :cascade do |t|
    t.bigint "page_revision_id", null: false
    t.integer "position", null: false
    t.string "block_type", null: false
    t.jsonb "configuration", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["page_revision_id", "position"], name: "index_page_blocks_on_page_revision_id_and_position", unique: true
    t.index ["page_revision_id"], name: "index_page_blocks_on_page_revision_id"
  end

  create_table "page_revisions", force: :cascade do |t|
    t.bigint "page_id", null: false
    t.bigint "template_revision_id", null: false
    t.bigint "created_by_id", null: false
    t.integer "version", null: false
    t.string "status", default: "draft", null: false
    t.string "title", null: false
    t.text "summary"
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_page_revisions_on_created_by_id"
    t.index ["page_id", "version"], name: "index_page_revisions_on_page_id_and_version", unique: true
    t.index ["page_id"], name: "index_page_revisions_on_page_id"
    t.index ["template_revision_id"], name: "index_page_revisions_on_template_revision_id"
    t.check_constraint "status::text = ANY (ARRAY['draft'::character varying, 'published'::character varying, 'archived'::character varying]::text[])", name: "page_revisions_status_check"
  end

  create_table "pages", force: :cascade do |t|
    t.bigint "template_id", null: false
    t.bigint "created_by_id", null: false
    t.string "slug", null: false
    t.string "locale", default: "en", null: false
    t.string "status", default: "draft", null: false
    t.bigint "published_revision_id"
    t.datetime "published_at"
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_pages_on_created_by_id"
    t.index ["locale", "slug"], name: "index_pages_on_locale_and_slug", unique: true
    t.index ["template_id"], name: "index_pages_on_template_id"
    t.check_constraint "status::text = ANY (ARRAY['draft'::character varying, 'published'::character varying, 'archived'::character varying]::text[])", name: "pages_status_check"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "template_blocks", force: :cascade do |t|
    t.bigint "template_revision_id", null: false
    t.integer "position", null: false
    t.string "block_type", null: false
    t.jsonb "configuration", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["template_revision_id", "position"], name: "index_template_blocks_on_template_revision_id_and_position", unique: true
    t.index ["template_revision_id"], name: "index_template_blocks_on_template_revision_id"
  end

  create_table "template_revisions", force: :cascade do |t|
    t.bigint "template_id", null: false
    t.bigint "created_by_id", null: false
    t.integer "version", null: false
    t.string "status", default: "draft", null: false
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_template_revisions_on_created_by_id"
    t.index ["template_id", "version"], name: "index_template_revisions_on_template_id_and_version", unique: true
    t.index ["template_id"], name: "index_template_revisions_on_template_id"
    t.check_constraint "status::text = ANY (ARRAY['draft'::character varying, 'published'::character varying, 'archived'::character varying]::text[])", name: "template_revisions_status_check"
  end

  create_table "templates", force: :cascade do |t|
    t.bigint "created_by_id", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.text "description"
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_templates_on_created_by_id"
    t.index ["slug"], name: "index_templates_on_slug", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.bigint "role_id", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
  end

  add_foreign_key "api_sessions", "users"
  add_foreign_key "page_blocks", "page_revisions"
  add_foreign_key "page_revisions", "pages"
  add_foreign_key "page_revisions", "template_revisions"
  add_foreign_key "page_revisions", "users", column: "created_by_id"
  add_foreign_key "pages", "page_revisions", column: "published_revision_id"
  add_foreign_key "pages", "templates"
  add_foreign_key "pages", "users", column: "created_by_id"
  add_foreign_key "template_blocks", "template_revisions"
  add_foreign_key "template_revisions", "templates"
  add_foreign_key "template_revisions", "users", column: "created_by_id"
  add_foreign_key "templates", "users", column: "created_by_id"
  add_foreign_key "users", "roles"
end
