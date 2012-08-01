Redmine::Plugin.register :redmine_cmdb do
end
  name 'Redmine CMDB plugin'
  description 'This plugin links Redmine with your web-based CMDB'
  author 'Jean-Baptiste BARTH'
  author_url 'mailto:jeanbaptiste.barth@gmail.com'
  version '0.0.1'
  url 'https://github.com/jbbarth/redmine_cmdb'
  requires_redmine :version_or_higher => '2.0.0'
  #requires_redmine_plugin :redmine_base_jquery, :version_or_higher => '0.0.1'
end
