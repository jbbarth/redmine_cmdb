require_dependency 'application_helper'

module ApplicationHelper
  def link_to_item(item)
    outage = ''
    outage = '5m' if item.name.match(/dev/)
    css_classes = 'configuration_item'
    content = content_tag(:span, item.name, :class => 'item')
    if outage.present?
      css_classes << ' has-outage'
      content << content_tag(:span, outage, :class => 'outage')
    end
    link_to(content, configuration_item_path(item), :class => css_classes)
  end

  def jquery_toggle_link(name, id, options={})
    onclick = "jQuery('#{id}').toggle(0, function() { "
    onclick << (options[:focus] ? "jQuery('#{options[:focus]}').focus(); " : "jQuery(this).blur(); ")
    onclick << "}); return false"
    link_to(name, "#", :onclick => onclick)
  end
end
