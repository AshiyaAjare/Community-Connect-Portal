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

ActiveRecord::Schema[7.2].define(version: 2025_01_29_055334) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "moderation_logs", force: :cascade do |t|
    t.integer "query_id"
    t.integer "response_id"
    t.integer "action", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["query_id"], name: "index_moderation_logs_on_query_id"
    t.index ["response_id"], name: "index_moderation_logs_on_response_id"
  end

  create_table "queries", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "title"
    t.string "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_queries_on_user_id"
  end

  create_table "query_tags", force: :cascade do |t|
    t.integer "query_id", null: false
    t.integer "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["query_id", "tag_id"], name: "index_query_tags_on_query_id_and_tag_id", unique: true
    t.index ["query_id"], name: "index_query_tags_on_query_id"
    t.index ["tag_id"], name: "index_query_tags_on_tag_id"
  end

  create_table "response_tags", force: :cascade do |t|
    t.integer "response_id", null: false
    t.integer "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["response_id", "tag_id"], name: "index_response_tags_on_response_id_and_tag_id", unique: true
    t.index ["response_id"], name: "index_response_tags_on_response_id"
    t.index ["tag_id"], name: "index_response_tags_on_tag_id"
  end

  create_table "responses", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "query_id", null: false
    t.text "content"
    t.integer "upvotes", default: 0
    t.integer "downvotes", default: 0
    t.integer "likes", default: 0
    t.boolean "approval", default: false
    t.boolean "flagged", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["query_id"], name: "index_responses_on_query_id"
    t.index ["user_id"], name: "index_responses_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.integer "role", default: 0, null: false
    t.string "password_digest"
    t.string "profile_image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "discarded_at"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "moderation_logs", "queries"
  add_foreign_key "moderation_logs", "responses"
  add_foreign_key "queries", "users"
  add_foreign_key "query_tags", "queries"
  add_foreign_key "query_tags", "tags"
  add_foreign_key "response_tags", "responses"
  add_foreign_key "response_tags", "tags"
  add_foreign_key "responses", "queries"
  add_foreign_key "responses", "users"
end
