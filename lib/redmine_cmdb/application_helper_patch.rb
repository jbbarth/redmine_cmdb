require_dependency 'application_helper'

module ApplicationHelper
  def link_to_item(item)
    outage = ''
    css_classes = 'configuration_item'
    content = content_tag(:span, item.name, :class => 'item')
    if outage.present?
      css_classes << ' has-outage'
      content << content_tag(:span, outage, :class => 'outage')
    end
    link_to(content, item.url, :class => css_classes)
  end
end
