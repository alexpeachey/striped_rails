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

ActiveRecord::Schema.define(:version => 20120228044200) do

  create_table "coupon_subscription_plans", :force => true do |t|
    t.integer  "coupon_id"
    t.integer  "subscription_plan_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "coupon_subscription_plans", ["coupon_id"], :name => "index_coupon_subscription_plans_on_coupon_id"
  add_index "coupon_subscription_plans", ["subscription_plan_id"], :name => "index_coupon_subscription_plans_on_subscription_plan_id"

  create_table "coupons", :force => true do |t|
    t.string   "coupon_code"
    t.integer  "percent_off",        :default => 0
    t.string   "duration"
    t.integer  "duration_in_months", :default => 0
    t.integer  "max_redemptions",    :default => 0
    t.integer  "times_redeemed",     :default => 0
    t.datetime "redeem_by"
    t.integer  "users_count",        :default => 0
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "coupons", ["coupon_code"], :name => "index_coupons_on_coupon_code", :unique => true
  add_index "coupons", ["redeem_by"], :name => "index_coupons_on_redeem_by"

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.string   "slug"
    t.text     "content"
    t.integer  "menu_order"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "pages", ["menu_order"], :name => "index_pages_on_menu_order"
  add_index "pages", ["slug"], :name => "index_pages_on_slug", :unique => true

  create_table "subscription_plans", :force => true do |t|
    t.string   "vault_token"
    t.string   "name"
    t.string   "currency"
    t.string   "interval"
    t.integer  "amount",            :default => 0
    t.integer  "trial_period_days", :default => 0
    t.string   "unit_name"
    t.integer  "included_units",    :default => 0
    t.integer  "overage_price",     :default => 0
    t.text     "description"
    t.boolean  "unavailable",       :default => false
    t.integer  "users_count",       :default => 0
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  add_index "subscription_plans", ["amount"], :name => "index_subscription_plans_on_amount"
  add_index "subscription_plans", ["unavailable"], :name => "index_subscription_plans_on_unavailable"
  add_index "subscription_plans", ["vault_token"], :name => "index_subscription_plans_on_vault_token", :unique => true

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "password_digest"
    t.string   "email"
    t.string   "full_name"
    t.string   "vault_token"
    t.integer  "subscription_plan_id"
    t.integer  "coupon_id"
    t.boolean  "is_admin",             :default => false
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  add_index "users", ["coupon_id"], :name => "index_users_on_coupon_id"
  add_index "users", ["created_at"], :name => "index_users_on_created_at"
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["subscription_plan_id"], :name => "index_users_on_subscription_plan_id"
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true
  add_index "users", ["vault_token"], :name => "index_users_on_vault_token"

end
