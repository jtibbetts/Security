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

ActiveRecord::Schema.define(version: 20151130142813) do

  create_table "events", force: :cascade do |t|
    t.string   "event_source", limit: 255
    t.string   "event_type",   limit: 255
    t.string   "event_name",   limit: 255
    t.string   "event_value",  limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "result_agents", force: :cascade do |t|
    t.string   "result_agent_id", limit: 255
    t.string   "label",           limit: 255
    t.text     "json_str",        limit: 65535
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "results", force: :cascade do |t|
    t.string   "context_id", limit: 255
    t.string   "user_id",    limit: 255
    t.string   "result",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

end
