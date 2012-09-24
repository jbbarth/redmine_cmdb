require File.dirname(__FILE__) + '/../test_helper'

class ConfigurationItemsControllerTest < ActionController::TestCase
  fixtures :users, :configuration_items

  setup do
    Setting.rest_api_enabled = '1'
    @key = User.find(1).api_key
  end

  context "#index" do
    context "without parameters" do
      should "list all records" do
        get :index, :format => :json, :key => @key
        assert_response :success
        assert_equal 'application/json', response.content_type

        json = ActiveSupport::JSON.decode(response.body)
        items = json['configuration_items']
        count = ConfigurationItem.active.count
        assert count >= 4
        assert_equal count, items.count
      end
    end

    context "with limit=N" do
      should "limit the number of results to N records" do
        get :index, :limit => 2, :format => :json, :key => @key

        json = ActiveSupport::JSON.decode(response.body)
        items = json['configuration_items']
        count = ConfigurationItem.count
        assert count >= 5
        assert_equal 2, items.count
      end
    end

    context "with search=<mask>" do
      should "return items with 'mask' in their name" do
        get :index, :search => "srv-app", :format => :json, :key => @key
        json = ActiveSupport::JSON.decode(response.body)
        ids = json['configuration_items'].map{ |item| item["id"] }
        assert ids.include?("2")
        assert ! ids.include?("3")
      end
    end

    context "with not=<id1,id2,...>" do
      should "not include specified id in results" do
        assert_equal "srv-app-01", ConfigurationItem.find(1).name
        get :index, :search => "srv-app", :not => "1,3", :format => :json, :key => @key
        json = ActiveSupport::JSON.decode(response.body)
        ids = json['configuration_items'].map{ |item| item["id"] }
        assert_equal %w(2), ids
      end
    end

    context "with status=<active|archived|all>" do
      should "delegate to ConfigurationItem.with_status(blah)" do
        get :index, :status => 'all', :format => :json, :key => @key
        json = ActiveSupport::JSON.decode(response.body)
        ids = json['configuration_items'].map{ |item| item["id"] }
        count = ConfigurationItem.count
        assert_equal count, ids.count

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
      should "render a link to CMDB" do
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
      should "really delete the record" do
        assert_difference 'ConfigurationItem.count', -1 do
          delete :destroy, :id => 3, :format => :json, :strategy => 'hard', :key => @key
          assert_response :success
        end
      end
    end

    context "with strategy = soft" do
      should "not delete the record, only set its active attribute to false" do
        assert_no_difference 'ConfigurationItem.count' do
          delete :destroy, :id => 3, :format => :json, :strategy => 'soft', :key => @key
          assert_response :success
        end
      end

      should "be the default strategy" do
        assert_no_difference 'ConfigurationItem.count' do
          delete :destroy, :id => 3, :format => :json, :key => @key
          assert_response :success
        end
      end
    end
  end
end
