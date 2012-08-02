class ConfigurationItemRelation < ActiveRecord::Base
  unloadable

  belongs_to :element, :polymorphic => true
  belongs_to :configuration_item

  validates_presence_of :configuration_item, :element
end
