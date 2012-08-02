require File.expand_path('../../test_helper', __FILE__)

class ConfigurationItemsApiTest < ActionController::IntegrationTest
  fixtures :users, :configuration_items

  setup do
    Setting.rest_api_enabled = '1'
  end

  #index
  context "GET /configuration_items" do
    should "get all configuration items" do
      get '/configuration_items.json', { }, credentials('admin')

      assert_response :success
      assert_equal 'application/json', response.content_type

      json = ActiveSupport::JSON.decode(response.body)
      ci = json['configuration_items'].detect{|c| c['name'] == 'srv-app-01'}
      assert_not_nil ci
      assert_equal 'Server', ci['item_type']
      assert_equal %w(id name description url item_type cmdb_identifier).sort, ci.keys.sort
    end
  end

  #show
  context "/configuration_items/:id" do
    should "get only one configuration item" do
      get '/configuration_items/1.json', { }, credentials('admin')

      assert_response :success
      assert_equal 'application/json', response.content_type

      json = ActiveSupport::JSON.decode(response.body)
      ci = json['configuration_item']
      assert_equal 'srv-app-01', ci['name']
      assert_equal 'Server', ci['item_type']
      assert_equal %w(id name description url item_type cmdb_identifier).sort, ci.keys.sort
    end
  end

  #create
  context "POST /configuration_items" do
    context "with valid parameters" do
      setup do
        @parameters = {:configuration_item => {:name => 'application-01', :item_type => 'application',
                                               :url => 'http://cmdb.host/application-01', :description => 'private app'}}
      end

      should "create a configuration_item with the attributes" do
        assert_difference('ConfigurationItem.count') do
          post '/configuration_items.json', @parameters, credentials('admin')
        end

        assert_response :created
        assert_equal 'application/json', response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        ci = json['configuration_item']
        assert_equal 'application-01', ci['name']

        configuration_item = ConfigurationItem.first(:order => 'id desc')
        assert_equal 'application-01', configuration_item.name
        assert_equal 'application', configuration_item.item_type
      end
    end

    context "with invalid parameters" do
      setup do
        @parameters = {:configuration_item => {:name => 'item-without-url'}}
      end

      should "return errors" do
        assert_no_difference('ConfigurationItem.count') do
          post '/configuration_items.json', @parameters, credentials('admin')
        end

        assert_response :unprocessable_entity
        assert_equal 'application/json', response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_equal "URL can't be blank", json['errors'].first
      end
    end
  end

  #update
  context "PUT /configuration_items/:id" do
    context "with valid parameters" do
      setup do
        @parameters = {:configuration_item => {:url => 'http://cmdb.host/applications/application-01'}}
      end

      should "update the configuration_item" do
        assert_no_difference 'ConfigurationItem.count' do
          put '/configuration_items/4.json', @parameters, credentials('admin')
        end
        assert_response :ok
        assert_equal 'application/json', response.content_type
        ci = ConfigurationItem.find(4)
        assert_equal 'http://cmdb.host/applications/application-01', ci.url
      end
    end

    context "with invalid parameters" do
      setup do
        @parameters = {:configuration_item => {:url => ''}}
      end

      should "return errors" do
        assert_no_difference('ConfigurationItem.count') do
          put '/configuration_items/4.json', @parameters, credentials('admin')
        end

        assert_response :unprocessable_entity
        assert_equal 'application/json', response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_equal "URL can't be blank", json['errors'].first
      end
    end
  end

  #destroy
  context "DELETE /configuration_items/:id" do
    should "delete the configuration_item" do
      assert_difference('ConfigurationItem.count', -1) do
        delete '/configuration_items/2.json', {:strategy => 'hard'}, credentials('admin')
      end
      assert_response :ok
      assert_nil ConfigurationItem.find_by_id(2)
    end
  end
end
