require File.dirname(__FILE__) + '/../test_helper'
require 'issues_controller'

class IssuesControllerWithCmdbTest < ActionController::TestCase
  fixtures :projects, :users, :roles, :members, :member_roles, :issues, :issue_statuses, :versions,
           :trackers, :projects_trackers, :issue_categories, :enabled_modules, :enumerations, :attachments,
           :workflows, :custom_fields, :custom_values, :custom_fields_projects, :custom_fields_trackers,
           :time_entries, :journals, :journal_details, :queries, :repositories, :changesets,
           :configuration_items, :configuration_item_relations

  include Redmine::I18n

  setup do
    @controller = IssuesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
    @request.session[:user_id] = 1 # => admin ; testing permissions is a bit boring sorry
    @project = Project.find(1)
    @project.enable_module!(:cmdb)
  end

  context "no related configuration item" do
    should "not show configuration items section" do
      get :show, :id => 1
      assert_equal [], ConfigurationItem.related_to(assigns(:issue))
      assert_no_tag 'strong', :content => 'Configuration items'
      assert_select 'a.configuration_item', false
    end
  end

  context "with some related configuration items" do
    should "show configuration items section" do
      get :show, :id => 2
      assert_tag 'strong', :content => 'Configuration items'
      assert_select 'a.configuration_item', :count => 1, :text => 'srv-app-01'
    end
  end
end
