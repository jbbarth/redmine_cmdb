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

  context "ConfigurationItem#related_to" do
    should "go through each ConfigurationItemRelation an item has" do
      issue = Issue.find(1)
      server = ConfigurationItem.find(1)
      assert_equal [], ConfigurationItem.related_to(issue)
      ConfigurationItemRelation.create!(configuration_item: server, element: issue)
      assert_equal [server], ConfigurationItem.related_to(issue)
    end

    should "return configuration items ordered by name asc" do
      issue = Issue.find(1)
      server = ConfigurationItem.find(1)  #srv-app*
      server2 = ConfigurationItem.find(3) #srv-db*
      ConfigurationItemRelation.create!(configuration_item: server2, element: issue)
      ConfigurationItemRelation.create!(configuration_item: server, element: issue)
      assert_equal [server, server2], ConfigurationItem.related_to(issue)
    end
  end
end
