class ConfigurationItemRelationsController < ApplicationController
  unloadable

  def create
    @relation = ConfigurationItemRelation.create(params[:relation])
    @configuration_items = ConfigurationItem.related_to(@relation.element)
    @configuration_item_relation = ConfigurationItemRelation.new(:element => @relation.element)
  end
end
