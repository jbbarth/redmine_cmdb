# Little hack for deface in redmine:
# - redmine plugins are not railties nor engines, so deface overrides are not detected automatically
# - deface doesn't support direct loading anymore ; it unloads everything at boot so that reload in dev works
# - hack consists in adding "app/overrides" path of the plugin in Redmine's main #paths
Rails.application.paths["app/overrides"] ||= []
Rails.application.paths["app/overrides"] << File.expand_path("../app/overrides", __FILE__)

ActionDispatch::Callbacks.to_prepare do
  require_dependency 'redmine_cmdb/application_helper_patch'
end

Redmine::Plugin.register :redmine_cmdb do
  name 'Redmine CMDB plugin'
  description 'This plugin links Redmine with your web-based CMDB'
  author 'Jean-Baptiste BARTH'
  author_url 'mailto:jeanbaptiste.barth@gmail.com'
  version '0.0.1'
  url 'https://github.com/jbbarth/redmine_cmdb'
  requires_redmine :version_or_higher => '2.0.0'
  #requires_redmine_plugin :redmine_base_jquery, :version_or_higher => '0.0.1'
  requires_redmine_plugin :redmine_base_rspec, :version_or_higher => '0.0.3' if Rails.env.test?
  project_module :cmdb do
    permission :view_configuration_items, { :configuration_items => [:index, :show] }
    permission :manage_configuration_items, { :configuration_items => [:create, :update, :destroy],
                                              :configuration_item_relations => [:create, :update, :destroy] }
  end
end
