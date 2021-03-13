class CreateAsOrganizations < ActiveRecord::Migration[6.0]
  def self.up
    # {"asn":"123","changed":"20201216","name":"SOME-THING-1","opaqueId":"abdad3adbadb3adb33a333da3adb3da_ARIN","organizationId":"SMT-1-ARIN","source":"ARIN","type":"ASN"}

    create_table :as_organizations do |t|
      t.bigint :asn, null: false
      t.string :name, null: false
      t.string :organization_iden, null: false
      t.string :source, null: false
      t.integer :changed_date
      t.string :opaque_iden
    end
  end

  def self.down
    drop_table :as_organizations
  end
end
