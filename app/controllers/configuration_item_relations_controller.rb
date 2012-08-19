class ConfigurationItemRelationsController < ApplicationController
  unloadable

  def create
    if params[:relation]
      "#{params[:relation][:configuration_item_id]}".strip.split(",").each do |id|
        @relation = ConfigurationItemRelation.create(params[:relation].merge("configuration_item_id" => id))
      end
      @configuration_items = ConfigurationItem.related_to(@relation.element)
      @configuration_item_relation = ConfigurationItemRelation.new(:element => @relation.element)
    end
  end
end
