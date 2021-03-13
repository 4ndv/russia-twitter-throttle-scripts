class AddAsnToLogs < ActiveRecord::Migration[6.0]
  def self.up
    add_column :logs, :asn, :integer
  end

  def self.down
    remove_column :logs, :asn
  end
end
