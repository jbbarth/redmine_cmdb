require "spec_helper"

describe IssuesController do
  render_views
  fixtures :projects, :users, :roles, :members, :member_roles, :issues, :issue_statuses, :versions,
           :trackers, :projects_trackers, :issue_categories, :enabled_modules, :enumerations, :attachments,
           :workflows, :custom_fields, :custom_values, :custom_fields_projects, :custom_fields_trackers,
           :time_entries, :journals, :journal_details, :queries, :repositories, :changesets,
           :configuration_items, :configuration_item_relations

  include Redmine::I18n

  before do
    @controller = IssuesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
    @request.session[:user_id] = 1 # => admin ; testing permissions is a bit boring sorry
    @project = Project.find(1)
    @project.enable_module!(:cmdb)
  end

  it "should show configuration items section" do
    get :show, :id => 2
    assert_tag 'strong', :content => 'Configuration items'
    assert_select 'a.configuration_item', :text => 'srv-app-01'
  end
end
