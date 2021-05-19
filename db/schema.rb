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

ActiveRecord::Schema.define(version: 2021_05_20_012845) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "as_organizations", force: :cascade do |t|
    t.bigint "asn", null: false
    t.string "name", null: false
    t.string "organization_iden", null: false
    t.string "source", null: false
    t.integer "changed_date"
    t.string "opaque_iden"
    t.string "country"
  end

  create_table "as_prefixes", force: :cascade do |t|
    t.cidr "prefix", null: false
    t.bigint "asn", null: false
    t.index ["prefix"], name: "index_as_prefixes_on_prefix", opclass: :inet_ops, using: :gist
  end

  create_table "logs", force: :cascade do |t|
    t.inet "ip", null: false
    t.datetime "datetime", null: false
    t.inet "anonymized_ip", null: false
    t.integer "version", null: false
    t.float "test_result", null: false
    t.float "control_result", null: false
    t.float "control_taco_result", null: false
    t.text "user_agent"
    t.integer "asn"
    t.cidr "subnet"
    t.string "as_country"
    t.text "as_organization"
    t.text "as_organization_iden"
    t.datetime "datetime_rounded"
    t.index ["ip", "datetime"], name: "index_logs_on_ip_and_datetime", unique: true
  end

end
