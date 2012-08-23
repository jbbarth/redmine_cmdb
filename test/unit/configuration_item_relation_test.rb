require File.dirname(__FILE__) + '/../test_helper'

class ConfigurationItemRelationTest < ActiveSupport::TestCase
  fixtures :configuration_items, :configuration_item_relations, :issues

  should "be able to create a CI relation" do
    cir = ConfigurationItemRelation.new
    assert ! cir.valid?
    cir.configuration_item = ConfigurationItem.first
    assert ! cir.valid?
    cir.element = Issue.first
    assert cir.valid?
    assert cir.save
  end

  context "ConfigurationItemRelation.for" do
    should "go through each ConfigurationItemRelation an item has" do
      issue = Issue.find(1)
      server = ConfigurationItem.find(1)
      assert_equal [], ConfigurationItemRelation.for(issue)
      cr = ConfigurationItemRelation.create!(configuration_item: server, element: issue)
      assert_equal [cr], ConfigurationItemRelation.for(issue)
    end

    should "return configuration items ordered by name asc" do
      issue = Issue.find(1)
      server = ConfigurationItem.find(1)  #srv-app*
      server2 = ConfigurationItem.find(3) #srv-db*
      cr2 = ConfigurationItemRelation.create!(configuration_item: server2, element: issue)
      cr1 = ConfigurationItemRelation.create!(configuration_item: server, element: issue)
      assert_equal [cr1, cr2], ConfigurationItemRelation.for(issue)
    end
  end
end
