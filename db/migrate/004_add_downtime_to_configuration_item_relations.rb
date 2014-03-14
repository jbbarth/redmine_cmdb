class AddDowntimeToConfigurationItemRelations < ActiveRecord::Migration
  def self.up
    add_column :configuration_item_relations, :downtime, :string
  end

  def self.down
    remove_column :configuration_item_relations, :downtime
  end
end
