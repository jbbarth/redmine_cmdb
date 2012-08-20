require File.dirname(__FILE__) + '/../test_helper'

class ConfigurationItemTest < ActiveSupport::TestCase
  fixtures :configuration_items

  should "create a ConfigurationItem object" do
    ci = ConfigurationItem.new
    assert ! ci.valid?
    ci.name = "server-01"
    assert ! ci.valid?
    ci.url = "http://cmdb.local/server-01"
    assert ci.valid?
    assert ci.save
    assert_equal true, ci.reload.active?
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

    context "#active?" do
      should "follow STATUS_* constants" do
        @ci.status = 1
        assert_equal true, @ci.active?
        @ci.status = 9
        assert_equal false, @ci.active?
        @ci.status = 17
        assert_equal false, @ci.active?
      end
    end

    context "#active" do
      should "return only active CIs" do
        count = ConfigurationItem.count
        assert_equal (count - 1), ConfigurationItem.active.count
        assert ! ConfigurationItem.active.include?(ConfigurationItem.find(5))
      end
    end

    context "#destroy" do
      should "soft destroy by default" do
        @ci.save
        assert_difference 'ConfigurationItem.active.count', -1 do
          assert_no_difference 'ConfigurationItem.count' do
            @ci.destroy
          end
        end
      end

      should "hard destroy if told" do
        @ci.save
        assert_difference 'ConfigurationItem.count', -1 do
          @ci.destroy('hard')
        end
      end
    end
  end

  context ".search" do
    should "not search pattern if no search pattern is passed" do
      assert_equal ConfigurationItem.count, ConfigurationItem.search("").count
    end

    should "limit objects to pattern if any" do
      assert ConfigurationItem.find(3).in?(ConfigurationItem.search("db"))
    end
  end

  context ".notin" do
    should "not bother if no param passed" do
      assert ConfigurationItem.notin("").count >= 5
      assert ConfigurationItem.notin.count >= 5
    end

    should "exclude ids if any" do
      assert ! ConfigurationItem.find(1).in?(ConfigurationItem.notin("2,1"))
    end
  end
end
