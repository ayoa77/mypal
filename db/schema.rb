# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170831041454) do

  create_table "city_images", force: :cascade do |t|
    t.integer "tag_id",     limit: 4
    t.string  "banner_uid", limit: 191
    t.string  "small_uid",  limit: 191
  end

  add_index "city_images", ["tag_id"], name: "index_city_images_on_tag_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.integer  "request_id",   limit: 4
    t.integer  "user_id",      limit: 4
    t.text     "content",      limit: 65535
    t.boolean  "enabled",                    default: true
    t.integer  "like_count",   limit: 4,     default: 0
    t.integer  "report_count", limit: 4,     default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["request_id"], name: "index_comments_on_request_id", using: :btree

  create_table "contacts", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "source",     limit: 4,   default: 0
    t.string   "email",      limit: 191
    t.string   "name",       limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contacts", ["user_id", "source", "email"], name: "index_contacts_on_user_id_and_source_and_email", unique: true, using: :btree

  create_table "conversation_users", force: :cascade do |t|
    t.integer  "conversation_id", limit: 4
    t.integer  "user_id",         limit: 4
    t.boolean  "unread",                    default: false
    t.datetime "last_read_at"
    t.boolean  "notified",                  default: false
  end

  add_index "conversation_users", ["conversation_id", "user_id"], name: "index_conversation_users_on_conversation_id_and_user_id", unique: true, using: :btree
  add_index "conversation_users", ["notified"], name: "index_conversation_users_on_notified", using: :btree
  add_index "conversation_users", ["unread"], name: "index_conversation_users_on_unread", using: :btree
  add_index "conversation_users", ["user_id"], name: "index_conversation_users_on_user_id", using: :btree

  create_table "conversations", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "conversations", ["updated_at"], name: "index_conversations_on_updated_at", using: :btree

  create_table "daily_stats", force: :cascade do |t|
    t.date    "date"
    t.integer "users",                limit: 4
    t.integer "daily_active_users",   limit: 4, default: 0
    t.integer "weekly_active_users",  limit: 4, default: 0
    t.integer "monthly_active_users", limit: 4
    t.integer "requests",             limit: 4
    t.integer "recent_requests",      limit: 4
    t.integer "conversations",        limit: 4
    t.integer "recent_conversations", limit: 4
  end

  add_index "daily_stats", ["date"], name: "index_daily_stats_on_date", unique: true, using: :btree

  create_table "email_settings", force: :cascade do |t|
    t.string   "email",         limit: 191
    t.boolean  "invitations",               default: true
    t.boolean  "conversations",             default: true
    t.boolean  "comments",                  default: true
    t.boolean  "recomments",                default: true
    t.boolean  "newfollowers",              default: true
    t.boolean  "newsletters",               default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "email_settings", ["email"], name: "index_email_settings_on_email", unique: true, using: :btree

  create_table "invitations", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "email",      limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invitations", ["email"], name: "index_invitations_on_email", using: :btree
  add_index "invitations", ["user_id", "email"], name: "index_invitations_on_user_id_and_email", unique: true, using: :btree

  create_table "locations", force: :cascade do |t|
    t.string   "city",         limit: 191
    t.string   "region",       limit: 191
    t.string   "country",      limit: 191
    t.string   "region_code",  limit: 191
    t.string   "country_code", limit: 191
    t.float    "lat",          limit: 24
    t.float    "lng",          limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "locations", ["city", "region", "country"], name: "index_locations_on_city_and_region_and_country", unique: true, using: :btree

  create_table "logs", force: :cascade do |t|
    t.text "content", limit: 65535
  end

  add_index "logs", ["content"], name: "index_search", type: :fulltext

  create_table "messages", force: :cascade do |t|
    t.integer  "conversation_id",  limit: 4
    t.integer  "user_id",          limit: 4
    t.boolean  "system_generated",               default: false
    t.text     "content",          limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "messages", ["conversation_id"], name: "index_messages_on_conversation_id", using: :btree
  add_index "messages", ["user_id"], name: "index_messages_on_user_id", using: :btree

  create_table "newsletters", force: :cascade do |t|
    t.string   "subject",    limit: 191
    t.string   "intro",      limit: 191
    t.text     "content",    limit: 65535
    t.boolean  "sent",                     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id",           limit: 4
    t.integer  "notification_type", limit: 4
    t.integer  "notable_id",        limit: 4
    t.string   "notable_type",      limit: 191
    t.integer  "from_user_id",      limit: 4
    t.integer  "from_user_count",   limit: 4,   default: 0
    t.boolean  "read",                          default: false
    t.boolean  "done",                          default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notifications", ["updated_at"], name: "index_notifications_on_updated_at", using: :btree
  add_index "notifications", ["user_id", "notification_type", "notable_type", "notable_id"], name: "one_notification_per_type", unique: true, using: :btree
  add_index "notifications", ["user_id", "read"], name: "index_notifications_on_user_id_and_read", using: :btree

  create_table "payments", force: :cascade do |t|
    t.string   "payment_id",   limit: 191
    t.decimal  "amount",                   precision: 10
    t.integer  "meeting_id",   limit: 4
    t.string   "redirect_url", limit: 191
    t.string   "token",        limit: 191
    t.string   "capture_id",   limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payments", ["capture_id"], name: "index_payments_on_capture_id", using: :btree
  add_index "payments", ["meeting_id"], name: "index_payments_on_meeting_id", using: :btree
  add_index "payments", ["token"], name: "index_payments_on_token", using: :btree

  create_table "ratings", force: :cascade do |t|
    t.integer  "user_id",       limit: 4
    t.integer  "rating",        limit: 4
    t.integer  "rateable_id",   limit: 4
    t.string   "rateable_type", limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ratings", ["rating"], name: "index_ratings_on_rating", using: :btree
  add_index "ratings", ["user_id", "rateable_id", "rateable_type"], name: "one_person_one_rating", unique: true, using: :btree
  add_index "ratings", ["user_id", "rateable_type"], name: "index_ratings_on_user_id_and_rateable_type", using: :btree
  add_index "ratings", ["user_id"], name: "index_ratings_on_user_id", using: :btree

  create_table "request_users", force: :cascade do |t|
    t.integer "request_id", limit: 4
    t.integer "user_id",    limit: 4
  end

  add_index "request_users", ["request_id", "user_id"], name: "index_request_users_on_request_id_and_user_id", unique: true, using: :btree
  add_index "request_users", ["user_id"], name: "index_request_users_on_user_id", using: :btree

  create_table "requests", force: :cascade do |t|
    t.integer  "user_id",          limit: 4
    t.string   "subject",          limit: 191
    t.text     "content",          limit: 65535
    t.text     "reward",           limit: 65535
    t.integer  "location_id",      limit: 4
    t.string   "workflow_state",   limit: 191
    t.integer  "user_reach_count", limit: 4,     default: 0
    t.integer  "like_count",       limit: 4,     default: 0
    t.integer  "report_count",     limit: 4,     default: 0
    t.integer  "comment_count",    limit: 4,     default: 0
    t.integer  "raw_score",        limit: 4,     default: 0
    t.float    "score",            limit: 24,    default: 1.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "requests", ["created_at"], name: "index_requests_on_created_at", using: :btree
  add_index "requests", ["location_id"], name: "index_requests_on_location_id", using: :btree
  add_index "requests", ["raw_score"], name: "index_requests_on_raw_score", using: :btree
  add_index "requests", ["score"], name: "index_requests_on_score", using: :btree
  add_index "requests", ["user_id"], name: "index_requests_on_user_id", using: :btree
  add_index "requests", ["workflow_state"], name: "index_requests_on_workflow_state", using: :btree

  create_table "settings", force: :cascade do |t|
    t.string "key",   limit: 191
    t.string "value", limit: 191
  end

  add_index "settings", ["key"], name: "index_settings_on_key", unique: true, using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id",        limit: 4
    t.integer  "taggable_id",   limit: 4
    t.string   "taggable_type", limit: 191
    t.integer  "tagger_id",     limit: 4
    t.string   "tagger_type",   limit: 191
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 191
    t.string  "display_name",   limit: 191
    t.string  "icon",           limit: 191, default: "hash"
    t.integer "user_id",        limit: 4
    t.integer "request_id",     limit: 4
    t.integer "taggings_count", limit: 4,   default: 0
    t.integer "user_count",     limit: 4,   default: 0
    t.string  "banner_url",     limit: 191
    t.string  "small_url",      limit: 191
  end

  add_index "tags", ["display_name"], name: "index_tags_on_display_name", using: :btree
  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree
  add_index "tags", ["user_count"], name: "index_tags_on_user_count", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                   limit: 191
    t.string   "name",                    limit: 191
    t.text     "biography",               limit: 65535
    t.string   "avatar_uid",              limit: 191
    t.string   "language",                limit: 191
    t.string   "paypal",                  limit: 191
    t.string   "website",                 limit: 191
    t.string   "linkedin_url",            limit: 191
    t.string   "linkedin_name",           limit: 191
    t.string   "facebook_url",            limit: 191
    t.string   "facebook_name",           limit: 191
    t.integer  "location_id",             limit: 4
    t.boolean  "enabled",                               default: true
    t.boolean  "admin",                                 default: false
    t.integer  "follower_count",          limit: 4,     default: 0
    t.integer  "following_count",         limit: 4,     default: 0
    t.integer  "report_count",            limit: 4,     default: 0
    t.integer  "request_count",           limit: 4,     default: 0
    t.integer  "request_like_count",      limit: 4,     default: 0
    t.integer  "comment_like_count",      limit: 4,     default: 0
    t.integer  "conversation_like_count", limit: 4,     default: 0
    t.integer  "point_count",             limit: 4,     default: 0
    t.string   "ip",                      limit: 191
    t.boolean  "online",                                default: false
    t.datetime "last_seen_at"
    t.datetime "last_fresh_new_posts_at"
    t.text     "active_sessions",         limit: 65535
    t.string   "socket_key",              limit: 191
    t.text     "keywords",                limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar_url",              limit: 191
  end

  add_index "users", ["admin"], name: "index_users_on_admin", using: :btree
  add_index "users", ["created_at"], name: "index_users_on_created_at", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["enabled"], name: "index_users_on_enabled", using: :btree
  add_index "users", ["last_seen_at"], name: "index_users_on_last_seen_at", using: :btree
  add_index "users", ["location_id"], name: "index_users_on_location_id", using: :btree
  add_index "users", ["online"], name: "index_users_on_online", using: :btree
  add_index "users", ["point_count"], name: "index_users_on_point_count", using: :btree

  create_table "viewings", force: :cascade do |t|
    t.integer  "viewable_id",   limit: 4
    t.string   "viewable_type", limit: 191
    t.integer  "user_id",       limit: 4
    t.integer  "view_count",    limit: 4,   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "viewings", ["user_id"], name: "index_viewings_on_user_id", using: :btree
  add_index "viewings", ["viewable_id", "viewable_type", "user_id"], name: "index_viewings_on_viewable_id_and_viewable_type_and_user_id", unique: true, using: :btree

end
