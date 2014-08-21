require "spec_helper"

describe "ApplicationHelperCmdbPatch" do
  include ApplicationHelper
  include ActionView::Helpers

  # avoid relying on real, db-backed items
  def configuration_item_path(item)
    "/path/to/#{item.name}"
  end

  it "should link to item without outage" do
    item = ConfigurationItem.new(:name => "srv")
    link_to_item(item).should == %(<a href="/path/to/srv" class="configuration_item"><span class="item">srv</span></a>)
  end

  it "should link to item with outage" do
    item = ConfigurationItem.new(:name => "srv")
    link_to_item(item, "5m").should == %(<a href="/path/to/srv" class="configuration_item has-outage"><span class="item">srv</span><span class="outage">5m</span></a>)
  end
end
