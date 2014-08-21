require "spec_helper"

describe "ConfigurationItemRelation" do
  fixtures :configuration_items, :configuration_item_relations, :issues

  it "should be able to create a CI relation" do
    cir = ConfigurationItemRelation.new
    assert ! cir.valid?
    cir.configuration_item = ConfigurationItem.first
    assert ! cir.valid?
    cir.element = Issue.first
    assert cir.valid?
    assert cir.save
  end

  context "ConfigurationItemRelation.for" do
    it "should go through each ConfigurationItemRelation an item has" do
      issue = Issue.find(1)
      server = ConfigurationItem.find(1)
      ConfigurationItemRelation.for(issue).should == []
      cr = ConfigurationItemRelation.create!(configuration_item: server, element: issue)
      ConfigurationItemRelation.for(issue).should == [cr]
    end

    it "should return configuration items ordered by name asc" do
      issue = Issue.find(1)
      server = ConfigurationItem.find(1)  #srv-app*
      server2 = ConfigurationItem.find(3) #srv-db*
      cr2 = ConfigurationItemRelation.create!(configuration_item: server2, element: issue)
      cr1 = ConfigurationItemRelation.create!(configuration_item: server, element: issue)
      ConfigurationItemRelation.for(issue).should == [cr1, cr2]
    end
  end
end
