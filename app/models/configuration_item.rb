class ConfigurationItem < ActiveRecord::Base
  unloadable

  validates_presence_of :name, :url
  validates_uniqueness_of :cmdb_identifier

  before_validation :populate_cmdb_identifier_if_blank!

  private
  def populate_cmdb_identifier_if_blank!
    self.cmdb_identifier = ["#{item_type}".parameterize, "::", "#{name}".parameterize].join if self.cmdb_identifier.blank?
    true
  end
end
