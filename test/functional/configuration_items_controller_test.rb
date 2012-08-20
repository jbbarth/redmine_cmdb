require File.dirname(__FILE__) + '/../test_helper'

class ConfigurationItemsControllerTest < ActionController::TestCase
  fixtures :users, :configuration_items

  setup do
    @controller = ConfigurationItemsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
    @request.session[:user_id] = 1 # => admin
  end

  context "#index" do
    context "without parameters" do
      should "list all records" do
        get :index, :format => :json
        assert_response :success
        assert_equal 'application/json', response.content_type

        json = ActiveSupport::JSON.decode(response.body)
        items = json['configuration_items']
        count = ConfigurationItem.count
        assert count >= 5
        assert_equal count, items.count
      end
    end

    context "with limit=N" do
      should "limit the number of results to N records" do
        get :index, :limit => 2, :format => :json

        json = ActiveSupport::JSON.decode(response.body)
        items = json['configuration_items']
        count = ConfigurationItem.count
        assert count >= 5
        assert_equal 2, items.count
      end
    end

    context "with search=<mask>" do
      should "return items with 'mask' in their name" do
        get :index, :search => "srv-app", :format => :json
        json = ActiveSupport::JSON.decode(response.body)
        ids = json['configuration_items'].map{ |item| item["id"] }
        assert ids.include?("2")
        assert ! ids.include?("3")
      end
    end

    context "with not=<id1,id2,...>" do
      should "not include specified id in results" do
        assert_equal "srv-app-01", ConfigurationItem.find(1).name
        get :index, :search => "srv-app", :not => "1,3", :format => :json
        json = ActiveSupport::JSON.decode(response.body)
        ids = json['configuration_items'].map{ |item| item["id"] }
        assert_equal %w(2), ids
      end
    end
  end

  context "#destroy" do
    context "with strategy = hard" do
      should "really delete the record" do
        assert_difference 'ConfigurationItem.count', -1 do
          delete :destroy, :id => 3, :strategy => 'hard'
        end
      end
    end

    context "with strategy = soft" do
      should "not delete the record, only set its active attribute to false" do
        assert_no_difference 'ConfigurationItem.count' do
          delete :destroy, :id => 3, :strategy => 'soft'
        end
      end

      should "be the default strategy" do
        assert_no_difference 'ConfigurationItem.count' do
          delete :destroy, :id => 3
        end
      end
    end
  end
end
