require File.dirname(__FILE__) + '/../../../test_helper'

class ApplicationHelperCmdbPatchTest < ActionView::TestCase
  include ApplicationHelper

  # avoid relying on real, db-backed items
  def configuration_item_path(item)
    "/path/to/#{item.name}"
  end

  def test_link_to_item_without_outage
    item = ConfigurationItem.new(:name => "srv")
    assert_equal %(<a href="/path/to/srv" class="configuration_item"><span class="item">srv</span></a>),
                 link_to_item(item)
  end

  def test_link_to_item_with_outage
    item = ConfigurationItem.new(:name => "srv")
    assert_equal %(<a href="/path/to/srv" class="configuration_item has-outage"><span class="item">srv</span><span class="outage">5m</span></a>),
                 link_to_item(item, "5m")
  end
end
