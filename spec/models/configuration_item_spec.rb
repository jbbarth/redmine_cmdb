require "spec_helper"
require "active_support/testing/assertions"

describe "ConfigurationItem" do
  include ActiveSupport::Testing::Assertions
  fixtures :configuration_items

  it "should create a ConfigurationItem object" do
    ci = ConfigurationItem.new
    assert ! ci.valid?
    ci.name = "server-01"
    assert ! ci.valid?
    ci.url = "http://cmdb.local/server-01"
    assert ci.valid?
    assert ci.save
    ci.reload.active?.should == true
  end

  context "with valid attributes" do
    before do
      @ci = ConfigurationItem.new(:name => "server-01", :url => "http://cmdb.local/server-01")
    end

    it "should populate #cmdb_identifier if blank" do
      ci = @ci.dup
      ci.save
      ci.reload.cmdb_identifier.should == "::server-01"
      ci = @ci.dup
      ci.item_type = "server"
      ci.save
      ci.reload.cmdb_identifier.should == "server::server-01"
    end

    it "should not populate #cmdb_identifier if provided" do
      @ci.cmdb_identifier = "123456"
      @ci.save
      @ci.reload.cmdb_identifier.should == "123456"
    end

    it "should ensure #cmdb_identifier is unique" do
      ci = @ci.dup
      assert @ci.save
      assert ! ci.save
      ci.errors[:cmdb_identifier].should == ["has already been taken"]
    end

    context "#active?" do
      it "should follow STATUS_* constants" do
        @ci.status = 1
        @ci.active?.should == true
        @ci.status = 9
        @ci.active?.should == false
        @ci.status = 17
        @ci.active?.should == false
      end
    end

    context "#active" do
      it "should return only active CIs" do
        count = ConfigurationItem.count
        ConfigurationItem.active.count.should == (count - 1)
        assert ! ConfigurationItem.active.include?(ConfigurationItem.find(5))
      end
    end

    context "#destroy" do
      it "should soft destroy by default" do
        @ci.save
        assert_difference 'ConfigurationItem.active.count', -1 do
          assert_no_difference 'ConfigurationItem.count' do
            @ci.destroy
          end
        end
      end

      it "should hard destroy if told" do
        @ci.save
        assert_difference 'ConfigurationItem.count', -1 do
          @ci.destroy('hard')
        end
      end
    end
  end

  context ".search" do
    it "should not search pattern if no search pattern is passed" do
      ConfigurationItem.search("").count.should == ConfigurationItem.count
    end

    it "should limit objects to pattern if any" do
      assert ConfigurationItem.find(3).in?(ConfigurationItem.search("db"))
    end
  end

  context ".notin" do
    it "should not bother if no param passed" do
      assert ConfigurationItem.notin("").count >= 5
      assert ConfigurationItem.notin.count >= 5
    end

    it "should exclude ids if any" do
      assert ! ConfigurationItem.find(1).in?(ConfigurationItem.notin("2,1"))
    end
  end

  context ".with_status" do
    it "should include active items by default" do
      items = ConfigurationItem.with_status('active')
      assert items.include?(ConfigurationItem.find(1))
      assert ! items.include?(ConfigurationItem.find(5))
    end

    it "should include only archived items if 'archived'" do
      items = ConfigurationItem.with_status('archived')
      assert ! items.include?(ConfigurationItem.find(1))
      assert items.include?(ConfigurationItem.find(5))
    end

    it "should include all items if 'all'" do
      items = ConfigurationItem.with_status('all')
      assert items.include?(ConfigurationItem.find(1))
      assert items.include?(ConfigurationItem.find(5))
    end

    it "should default to active if no keyword or invalid one specified" do
      items = ConfigurationItem.with_status('blah')
      assert items.include?(ConfigurationItem.find(1))
      assert ! items.include?(ConfigurationItem.find(5))
      items = ConfigurationItem.with_status(nil)
      assert items.include?(ConfigurationItem.find(1))
      assert ! items.include?(ConfigurationItem.find(5))
    end
  end
end
