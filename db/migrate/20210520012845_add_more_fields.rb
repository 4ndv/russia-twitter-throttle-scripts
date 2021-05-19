class AddMoreFields < ActiveRecord::Migration[6.0]
  def self.up
    add_column :logs, :as_country, :string
    add_column :logs, :as_organization, :text
    add_column :logs, :as_organization_iden, :text
    add_column :logs, :datetime_rounded, :timestamp

    add_column :as_organizations, :country, :string
  end

  def self.down
    remove_column :logs, :as_country
    remove_column :logs, :as_organization
    remove_column :logs, :as_organization_iden
    remove_column :logs, :datetime_rounded

    remove_column :as_organizations, :country
  end
end
