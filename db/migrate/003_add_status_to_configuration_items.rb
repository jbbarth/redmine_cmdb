class AddStatusToConfigurationItems < ActiveRecord::Migration
  def self.up
    add_column :configuration_items, :status, :integer, :default => 1, :null => false
  end

  def self.down
    remove_column :configuration_items, :status
  end
end
