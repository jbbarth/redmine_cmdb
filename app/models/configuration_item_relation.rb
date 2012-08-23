class ConfigurationItemRelation < ActiveRecord::Base
  unloadable

  belongs_to :element, :polymorphic => true
  belongs_to :configuration_item

  validates_presence_of :configuration_item, :element

  class << self
    def for(element)
      ConfigurationItemRelation.where(element_type: element.class.to_s, element_id: element.id)
                               .includes(:configuration_item)
                               .order('configuration_items.name asc')
    end
  end
end
