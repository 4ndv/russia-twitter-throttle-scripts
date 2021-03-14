class AddSubnetToLogs < ActiveRecord::Migration[6.0]
  def self.up
    add_column :logs, :subnet, :cidr
  end

  def self.down
    remove_column :logs, :subnet
  end
end
