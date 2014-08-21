require "spec_helper"
require "active_support/testing/assertions"

describe ConfigurationItemRelationsController do
  include ActiveSupport::Testing::Assertions
  fixtures :projects, :users, :roles, :members, :member_roles, :issues, :issue_statuses,
           :issue_relations, :enabled_modules, :enumerations, :trackers,
           :configuration_items, :configuration_item_relations

  before do
    @controller = ConfigurationItemRelationsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
    @request.session[:user_id] = 1 # admin ; permission problems are too hard
    Project.find(1).enable_module!(:cmdb)
  end

  context "#create" do
    it "should create a new ConfigruationItemRelation with xhr" do
      assert_difference 'ConfigurationItemRelation.count' do
        xhr :post, :create, :project_id => 1, :relation => {
          :configuration_item_id => '1', :element_type => 'Issue', :element_id => '2'
        }
      end
      relation = ConfigurationItemRelation.first(:order => 'id DESC')
      relation.element.should == Issue.find(2)
      relation.configuration_item_id.should == 1
    end

    it "should create multiple ConfigruationItemRelation with xhr" do
      ConfigurationItemRelation.for(Issue.find(3)).should == []
      assert_difference 'ConfigurationItemRelation.count', 2 do
        xhr :post, :create, :project_id => 1, :relation => {
          :configuration_item_id => '1,2', :element_type => 'Issue', :element_id => '3'
        }
      end
      relations = ConfigurationItemRelation.order(:id).last(2)
      relations.map(&:element).uniq.should == [Issue.find(3)]
      relations.map(&:configuration_item_id).should == [1,2]
    end
  end

  context "#destroy" do
    it "should destroy the requested relation" do
      ci = ConfigurationItemRelation.first
      assert_difference 'ConfigurationItemRelation.count', -1 do
        xhr :delete, :destroy, :project_id => 1, :id => ci.id
      end
    end
  end
end
