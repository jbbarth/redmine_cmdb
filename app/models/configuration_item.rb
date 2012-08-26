class ConfigurationItem < ActiveRecord::Base
  unloadable

  has_many :configuration_item_relations, :dependent => :destroy

  # Config item available statuses
  STATUS_ACTIVE     = 1
  STATUS_ARCHIVED   = 9

  validates_presence_of :name, :url
  validates_uniqueness_of :cmdb_identifier

  before_validation :populate_cmdb_identifier_if_blank!

  scope :active, where(status: STATUS_ACTIVE)

  class << self
    def search(term)
      term.present? ? where("LOWER(name) LIKE ?", "%#{term.downcase}%") : scoped
    end

    def notin(ids = '')
      ids.present? ? where('id NOT IN (?)', ids.split(",")) : scoped
    end

    def with_status(status = 'active')
      case status
      when 'all'
        scoped
      when 'archived'
        where(status: STATUS_ARCHIVED)
      else
        active #scope
      end
    end
  end

  def active?
    self.status == STATUS_ACTIVE
  end

  def destroy(strategy = 'soft')
    if strategy == 'hard'
      super()
    else
      update_attribute(:status, STATUS_ARCHIVED)
    end
  end

  private
  def populate_cmdb_identifier_if_blank!
    self.cmdb_identifier = ["#{item_type}".parameterize, "::", "#{name}".parameterize].join if self.cmdb_identifier.blank?
    true
  end
end
