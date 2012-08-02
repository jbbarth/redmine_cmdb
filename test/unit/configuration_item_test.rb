require File.dirname(__FILE__) + '/../test_helper'

class ConfigurationItemTest < ActiveSupport::TestCase
  should "create a ConfigurationItem object" do
    assert ! ConfigurationItem.new().valid?
    assert ! ConfigurationItem.new(:name => "server-01").valid?
    assert ! ConfigurationItem.new(:url => "http://cmdb.local/server-01").valid?
    assert   ConfigurationItem.new(:name => "server-01", :url => "http://cmdb.local/server-01").valid?
  end

  context "with valid attributes" do
    setup do
      @ci = ConfigurationItem.new(:name => "server-01", :url => "http://cmdb.local/server-01")
    end

    should "populate #cmdb_identifier if blank" do
      ci = @ci.dup
      ci.save
      assert_equal "::server-01", ci.reload.cmdb_identifier
      ci = @ci.dup
      ci.item_type = "server"
      ci.save
      assert_equal "server::server-01", ci.reload.cmdb_identifier
    end

    should "not populate #cmdb_identifier if provided" do
      @ci.cmdb_identifier = "123456"
      @ci.save
      assert_equal "123456", @ci.reload.cmdb_identifier
    end

    should "ensure #cmdb_identifier is unique" do
      ci = @ci.dup
      assert @ci.save
      assert ! ci.save
      assert_equal ["has already been taken"], ci.errors[:cmdb_identifier]
    end
  end
end
