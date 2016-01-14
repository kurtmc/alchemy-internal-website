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

ActiveRecord::Schema.define(version: 20160114010020) do

  create_table "customers", force: true do |t|
    t.string   "customer_id"
    t.string   "name"
    t.decimal  "balance"
    t.decimal  "credit_limit"
    t.decimal  "current"
    t.decimal  "last_1_to_30"
    t.decimal  "last_31_to_60"
    t.decimal  "last_31_90"
    t.decimal  "last_90_plus"
    t.integer  "salesperson_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "customers", ["salesperson_id"], name: "index_customers_on_salesperson_id"

  create_table "navisions", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: true do |t|
    t.string   "product_id"
    t.string   "directory"
    t.string   "sds"
    t.string   "pds"
    t.string   "vendor_id"
    t.string   "vendor_name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "sds_expiry"
    t.string   "description2"
    t.string   "unit_measure"
    t.string   "shelf_life"
    t.decimal  "inventory"
    t.decimal  "quantity_purchase_order"
    t.decimal  "quantity_packing_slip"
  end

  create_table "sales_people", force: true do |t|
    t.string   "salesperson_code"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
