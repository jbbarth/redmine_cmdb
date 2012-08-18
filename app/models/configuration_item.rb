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
    def related_to(element)
      ConfigurationItemRelation.where(element_type: element.class.to_s, element_id: element.id)
                               .includes(:configuration_item)
                               .order('configuration_items.name asc')
                               .map(&:configuration_item)
    end

    def search(term)
      if term.present?
        where("LOWER(name) LIKE ?", "%#{term.downcase}%")
      else
        scoped
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
