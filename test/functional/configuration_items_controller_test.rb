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
