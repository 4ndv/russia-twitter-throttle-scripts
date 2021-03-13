class CreateTestItems < ActiveRecord::Migration[6.0]
  def self.up
    create_table :logs do |t|
      t.inet :ip, null: false
      t.datetime :datetime, null: false
      t.inet :anonymized_ip, null: false
      t.integer :version, null: false
      t.float :test_result, null: false
      t.float :control_result, null: false
      t.float :control_taco_result, null: false
      t.text :user_agent
    end

    add_index :logs, [:ip, :datetime], unique: true
  end

  def self.down
    drop_table :logs
  end
end
