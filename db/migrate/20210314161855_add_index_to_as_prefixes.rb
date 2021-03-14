class AddIndexToAsPrefixes < ActiveRecord::Migration[6.0]
  def self.up
    add_index :as_prefixes, :prefix, using: :gist, opclass: :inet_ops
  end

  def self.down
    remove_index :as_prefixes, :prefix
  end
end
