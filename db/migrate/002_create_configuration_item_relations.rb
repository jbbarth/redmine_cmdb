class CreateConfigurationItemRelations < ActiveRecord::Migration
  def self.up
    create_table :configuration_item_relations do |t|
      t.column :configuration_item_id, :integer, :null => false
      t.column :element_type, :string, :null => false
      t.column :element_id, :integer, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :configuration_item_relations
  end
end
