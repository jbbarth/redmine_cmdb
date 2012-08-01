class CreateConfigurationItems < ActiveRecord::Migration
  def self.up
    create_table :configuration_items do |t|
      t.column :name, :string
      t.column :item_type, :string
      t.column :url, :string
      t.column :description, :text
      t.column :cmdb_identifier, :string
    end
  end

  def self.down
    drop_table :configuration_items
  end
end
