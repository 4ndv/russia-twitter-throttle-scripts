class CreateAsPrefixes < ActiveRecord::Migration[6.0]
  def self.up
    create_table :as_prefixes do |t|
      t.cidr :prefix, null: false
      t.bigint :asn, null: false
    end
  end

  def self.down
    drop_table :as_prefixes
  end
end
