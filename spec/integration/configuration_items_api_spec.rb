require "spec_helper"
require "active_support/testing/assertions"

describe "ConfigurationItemsApi" do
  include ActiveSupport::Testing::Assertions
  fixtures :users, :configuration_items

  before do
    Setting.rest_api_enabled = '1'
  end

  #taken from core test/test_helper
  def credentials(user, password=nil)
    {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(user, password || user)}
  end

  #index
  context "GET /configuration_items" do
    it "should get all configuration items" do
      get '/configuration_items.json', { }, credentials('admin')

      response.should be_success
      response.content_type.should == 'application/json'

      json = ActiveSupport::JSON.decode(response.body)
      ci = json['configuration_items'].detect{|c| c['name'] == 'srv-app-01'}
      assert_not_nil ci
      ci['item_type'].should == 'Server'
      ci.keys.sort.should == %w(id name description url item_type cmdb_identifier active).sort
      ci['active'].should == true
    end
  end

  #show
  context "/configuration_items/:id" do
    it "should get only one configuration item" do
      get '/configuration_items/1.json', { }, credentials('admin')

      response.should be_success
      response.content_type.should == 'application/json'

      json = ActiveSupport::JSON.decode(response.body)
      ci = json['configuration_item']
      ci['name'].should == 'srv-app-01'
      ci['item_type'].should == 'Server'
      ci.keys.sort.should == %w(id name description url item_type cmdb_identifier active).sort
      ci['active'].should == true
    end
  end

  #create
  context "POST /configuration_items" do
    context "with valid parameters" do
      before do
        @parameters = {:configuration_item => {:name => 'application-01', :item_type => 'application',
                                               :url => 'http://cmdb.host/application-01', :description => 'private app'}}
      end

      it "should create a configuration_item with the attributes" do
        assert_difference('ConfigurationItem.count') do
          post '/configuration_items.json', @parameters, credentials('admin')
        end

        assert_response :created
        response.content_type.should == 'application/json'
        json = ActiveSupport::JSON.decode(response.body)
        ci = json['configuration_item']
        ci['name'].should == 'application-01'

        configuration_item = ConfigurationItem.first(:order => 'id desc')
        configuration_item.name.should == 'application-01'
        configuration_item.item_type.should == 'application'
      end
    end

    context "with invalid parameters" do
      before do
        @parameters = {:configuration_item => {:name => 'item-without-url'}}
      end

      it "should return errors" do
        assert_no_difference('ConfigurationItem.count') do
          post '/configuration_items.json', @parameters, credentials('admin')
        end

        assert_response :unprocessable_entity
        response.content_type.should == 'application/json'
        json = ActiveSupport::JSON.decode(response.body)
        json['errors'].first.should == "URL can't be blank"
      end
    end
  end

  #update
  context "PUT /configuration_items/:id" do
    context "with valid parameters" do
      before do
        @parameters = {:configuration_item => {:url => 'http://cmdb.host/applications/application-01'}}
      end

      it "should update the configuration_item" do
        assert_no_difference 'ConfigurationItem.count' do
          put '/configuration_items/4.json', @parameters, credentials('admin')
        end
        assert_response :ok
        response.content_type.should == 'application/json'
        ci = ConfigurationItem.find(4)
        ci.url.should == 'http://cmdb.host/applications/application-01'
      end
    end

    context "with invalid parameters" do
      before do
        @parameters = {:configuration_item => {:url => ''}}
      end

      it "should return errors" do
        assert_no_difference('ConfigurationItem.count') do
          put '/configuration_items/4.json', @parameters, credentials('admin')
        end

        assert_response :unprocessable_entity
        response.content_type.should == 'application/json'
        json = ActiveSupport::JSON.decode(response.body)
        json['errors'].first.should == "URL can't be blank"
      end
    end
  end

  #destroy
  context "DELETE /configuration_items/:id" do
    it "should delete the configuration_item" do
      assert_difference('ConfigurationItem.count', -1) do
        delete '/configuration_items/2.json', {:strategy => 'hard'}, credentials('admin')
      end
      assert_response :ok
      assert_nil ConfigurationItem.find_by_id(2)
    end
  end
end
