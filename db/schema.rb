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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121016193850) do

  create_table "aggregate_projects", :force => true do |t|
    t.string   "name"
    t.boolean  "enabled",                  :default => true
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.string   "code"
    t.string   "location",   :limit => 20
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.string   "queue"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "payload_log_entries", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "project_id"
    t.string   "status"
    t.string   "method"
    t.text     "error_text"
    t.text     "backtrace"
    t.string   "error_type"
  end

  add_index "payload_log_entries", ["created_at"], :name => "index_payload_log_entries_on_created_at"
  add_index "payload_log_entries", ["project_id", "created_at"], :name => "index_payload_log_entries_on_project_id_and_created_at"

  create_table "project_statuses", :force => true do |t|
    t.boolean  "success",      :default => false, :null => false
    t.string   "url"
    t.datetime "published_at"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "error"
    t.integer  "build_id"
  end

  add_index "project_statuses", ["project_id", "published_at"], :name => "index_project_statuses_on_project_id_and_others"

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.string   "deprecated_feed_url"
    t.string   "auth_username"
    t.string   "auth_password"
    t.boolean  "enabled",                                    :default => true
    t.boolean  "building",                                   :default => false, :null => false
    t.string   "type"
    t.integer  "polling_interval"
    t.datetime "next_poll_at"
    t.integer  "aggregate_project_id"
    t.integer  "deprecated_latest_status_id"
    t.string   "code"
    t.string   "deprecated_location",          :limit => 20
    t.string   "tracker_project_id"
    t.string   "tracker_auth_token"
    t.integer  "current_velocity",                           :default => 0,     :null => false
    t.string   "last_ten_velocities"
    t.boolean  "tracker_online"
    t.string   "cruise_control_rss_feed_url"
    t.string   "jenkins_base_url"
    t.string   "jenkins_build_name"
    t.string   "team_city_base_url"
    t.string   "team_city_build_id"
    t.string   "team_city_rest_base_url"
    t.string   "team_city_rest_build_type_id"
    t.string   "travis_github_account"
    t.string   "travis_repository"
    t.boolean  "online",                                     :default => false
    t.boolean  "has_failing_children",                       :default => false, :null => false
    t.boolean  "has_building_children",                      :default => false, :null => false
    t.string   "guid"
    t.boolean  "webhooks_enabled"
    t.string   "tracker_validation_status"
    t.datetime "last_refreshed_at"
    t.string   "semaphore_api_url"
    t.string   "parsed_url"
    t.string   "tddium_auth_token"
    t.string   "tddium_project_name"
    t.string   "notification_email"
    t.boolean  "send_build_notifications"
    t.boolean  "send_error_notifications"
    t.boolean  "verify_ssl",                                 :default => true
  end

  add_index "projects", ["aggregate_project_id"], :name => "index_projects_on_aggregate_project_id"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                  :limit => 40
    t.string   "name",                   :limit => 100, :default => ""
    t.string   "email",                  :limit => 100
    t.string   "encrypted_password",                    :default => "", :null => false
    t.string   "password_salt",          :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "provider"
    t.string   "uid"
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
