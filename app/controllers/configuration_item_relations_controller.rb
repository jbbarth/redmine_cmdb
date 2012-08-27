class ConfigurationItemRelationsController < ApplicationController
  unloadable

  before_filter :find_project_by_project_id
  before_filter :authorize

  def create
    if params[:relation]
      "#{params[:relation][:configuration_item_id]}".strip.split(",").each do |id|
        @relation = ConfigurationItemRelation.create(params[:relation].merge("configuration_item_id" => id))
      end
      @configuration_item_relations = ConfigurationItemRelation.for(@relation.element)
      @configuration_item_relation = ConfigurationItemRelation.new(:element => @relation.element)
    end
  end

  def destroy
    @relation = ConfigurationItemRelation.where(:id => params[:id]).first
    @relation.destroy
  end
end
