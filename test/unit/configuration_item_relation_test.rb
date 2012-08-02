require File.dirname(__FILE__) + '/../test_helper'

class ConfigurationItemRelationTest < ActiveSupport::TestCase
  fixtures :configuration_items, :issues

  should "be able to create a CI relation" do
    cir = ConfigurationItemRelation.new
    assert ! cir.valid?
    cir.configuration_item = ConfigurationItem.first
    assert ! cir.valid?
    cir.element = Issue.first
    assert cir.valid?
    assert cir.save
  end
end
