require File.expand_path('../../test_helper', __FILE__)

class ConfigurationItemRelationsControllerTest < ActionController::TestCase
  fixtures :projects, :users, :roles, :members, :member_roles, :issues, :issue_statuses,
           :issue_relations, :enabled_modules, :enumerations, :trackers,
           :configuration_items, :configuration_item_relations

  setup do
    @controller = ConfigurationItemRelationsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
    @request.session[:user_id] = 1 # admin ; permission problems are too hard
  end

  context "#create" do
    should "create a new ConfigruationItemRelation with xhr" do
      assert_difference 'ConfigurationItemRelation.count' do
        xhr :post, :create, :relation => {
          :configuration_item_id => '1', :element_type => 'Issue', :element_id => '2'
        }
      end
      relation = ConfigurationItemRelation.first(:order => 'id DESC')
      assert_equal Issue.find(2), relation.element
      assert_equal 1, relation.configuration_item_id
    end

    should "create multiple ConfigruationItemRelation with xhr" do
      assert_equal [], ConfigurationItemRelation.for(Issue.find(3))
      assert_difference 'ConfigurationItemRelation.count', 2 do
        xhr :post, :create, :relation => {
          :configuration_item_id => '1,2', :element_type => 'Issue', :element_id => '3'
        }
      end
      relations = ConfigurationItemRelation.order(:id).last(2)
      assert_equal [Issue.find(3)], relations.map(&:element).uniq
      assert_equal [1,2], relations.map(&:configuration_item_id)
    end
  end

  context "#destroy" do
    should "destroy the requested relation" do
      assert_difference 'ConfigurationItemRelation.count', -1 do
        xhr :delete, :destroy, :id => 1
      end
    end
  end
end
