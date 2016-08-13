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

ActiveRecord::Schema.define(version: 20160813091623) do

  create_table "active_admin_comments", force: true do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"

  create_table "agencies", force: true do |t|
    t.string   "agency_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "agencies_vendors", id: false, force: true do |t|
    t.integer "agency_id"
    t.integer "vendor_id"
  end

  create_table "customer_users", force: true do |t|
    t.string   "email"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "company_name"
    t.boolean  "terms_of_use", default: false
  end

  create_table "customer_users_products", id: false, force: true do |t|
    t.integer "product_id",       null: false
    t.integer "customer_user_id", null: false
  end

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
    t.integer  "sales_person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "customers", ["sales_person_id"], name: "index_customers_on_sales_person_id"

  create_table "document_types", force: true do |t|
    t.string   "type_code"
    t.string   "type_description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "documents", force: true do |t|
    t.integer  "document_type_id"
    t.string   "absolute_directory"
    t.string   "filename"
    t.date     "expiration"
    t.integer  "product_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "documents", ["document_type_id"], name: "index_documents_on_document_type_id"
  add_index "documents", ["product_id"], name: "index_documents_on_product_id"

  create_table "navision_records", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "navisions", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notice_boards", force: true do |t|
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "prices", force: true do |t|
    t.string   "item_id"
    t.string   "unit_measure"
    t.decimal  "min_quantity"
    t.decimal  "published_price"
    t.decimal  "cost"
    t.decimal  "price"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "prices", ["customer_id"], name: "index_prices_on_customer_id"

  create_table "products", force: true do |t|
    t.string   "product_id"
    t.string   "directory"
    t.integer  "vendor_id",               limit: 255
    t.string   "description"
    t.string   "description2"
    t.datetime "sds_expiry"
    t.string   "unit_measure"
    t.string   "shelf_life"
    t.decimal  "inventory"
    t.decimal  "quantity_purchase_order"
    t.decimal  "quantity_packing_slip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "sds_required"
    t.string   "new_description"
    t.integer  "customer_user_id"
    t.integer  "document_id"
  end

  add_index "products", ["customer_user_id"], name: "index_products_on_customer_user_id"
  add_index "products", ["document_id"], name: "index_products_on_document_id"

  create_table "sales_people", force: true do |t|
    t.string   "salesperson_code"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.boolean  "admin"
    t.boolean  "api_user"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  create_table "vendors", force: true do |t|
    t.string   "vendor_id"
    t.string   "vendor_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "agency_id"
  end

  add_index "vendors", ["agency_id"], name: "index_vendors_on_agency_id"

end
