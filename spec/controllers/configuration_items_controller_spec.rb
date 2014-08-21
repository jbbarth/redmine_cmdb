require "spec_helper"
require "active_support/testing/assertions"

describe ConfigurationItemsController do
  render_views
  include ActiveSupport::Testing::Assertions
  fixtures :users, :configuration_items

  before do
    Setting.rest_api_enabled = '1'
    @key = User.find(1).api_key
  end

  context "#index" do
    context "without parameters" do
      it "should list all records" do
        get :index, :format => :json, :key => @key
        response.should be_success
        response.content_type.should == 'application/json'

        json = ActiveSupport::JSON.decode(response.body)
        items = json['configuration_items']
        count = ConfigurationItem.active.count
        assert count >= 4
        items.count.should == count
      end
    end

    context "with limit=N" do
      it "should limit the number of results to N records" do
        get :index, :limit => 2, :format => :json, :key => @key

        json = ActiveSupport::JSON.decode(response.body)
        items = json['configuration_items']
        count = ConfigurationItem.count
        assert count >= 5
        items.count.should == 2
      end
    end

    context "with search=<mask>" do
      it "should return items with 'mask' in their name" do
        get :index, :search => "srv-app", :format => :json, :key => @key
        json = ActiveSupport::JSON.decode(response.body)
        ids = json['configuration_items'].map{ |item| item["id"] }
        assert ids.include?("2")
        assert ! ids.include?("3")
      end
    end

    context "with not=<id1,id2,...>" do
      it "should not include specified id in results" do
        ConfigurationItem.find(1).name.should == "srv-app-01"
        get :index, :search => "srv-app", :not => "1,3", :format => :json, :key => @key
        json = ActiveSupport::JSON.decode(response.body)
        ids = json['configuration_items'].map{ |item| item["id"] }
        ids.should == %w(2)
      end
    end

    context "with status=<active|archived|all>" do
      it "should delegate to ConfigurationItem.with_status(blah)" do
        get :index, :status => 'all', :format => :json, :key => @key
        json = ActiveSupport::JSON.decode(response.body)
        ids = json['configuration_items'].map{ |item| item["id"] }
        count = ConfigurationItem.count
        ids.count.should == count

        get :index, :status => 'archived', :format => :json, :key => @key
        json = ActiveSupport::JSON.decode(response.body)
        ids = json['configuration_items'].map{ |item| item["id"] }
        assert !ids.include?('1')
        assert ids.include?('5')
      end
    end
  end

  context "#show" do
    context "in html format" do
      it "should render a link to CMDB" do
        @request.session[:user_id] = 1
        get :show, :id => 1
        assert_template 'configuration_items/show'
        assert_select 'h2', :text => 'Server srv-app-01'
        assert_select 'div.contextual a', :text => 'Open in CMDB'
      end
    end
  end

  context "#destroy" do
    context "with strategy = hard" do
      it "should really delete the record" do
        assert_difference 'ConfigurationItem.count', -1 do
          delete :destroy, :id => 3, :format => :json, :strategy => 'hard', :key => @key
          response.should be_success
        end
      end
    end

    context "with strategy = soft" do
      it "should not delete the record, only set its active attribute to false" do
        assert_no_difference 'ConfigurationItem.count' do
          delete :destroy, :id => 3, :format => :json, :strategy => 'soft', :key => @key
          response.should be_success
        end
      end

      it "should be the default strategy" do
        assert_no_difference 'ConfigurationItem.count' do
          delete :destroy, :id => 3, :format => :json, :key => @key
          response.should be_success
        end
      end
    end
  end
end
