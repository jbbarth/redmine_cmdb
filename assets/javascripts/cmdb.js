$(function() {
  window.selectifyConfigurationItemRelation = function() {
    $("#relation_configuration_item_id").select2({
      minimumInputLength: 1,
      multiple: true,
      ajax: {
        dataType: 'json',
        data: function (term, page) {
          return { search: term, limit: 10, not: $("#relation_configuration_item_id").data("currentIds") }
        },
        results: function (data, page) {
          var groups = {}, result = { results: [] }
          $.each(data.configuration_items, function() {
            if (!groups[this.item_type]) { groups[this.item_type] = {text: this.item_type, children: []} }
            groups[this.item_type].children.push({id: this.id, text: this.name})
          })
          for (var group in groups) {
            result.results.push(groups[group])
          }
          return result
        }
      },
      formatInputTooShort: function() { return "" },
      formatSearching: function() { return "..." },
      formatNoMatches: function() { return $("#relation_configuration_item_id").data("noMatches") },
      formatResult: function(e) { return e.text },
      containerCssClass: 'configuration-items-select2',
      dropdownCssClass: 'configuration-items-select2-dropdown',
      closeOnSelect: false,
      zformatSelection: function() { }
    });
  }
  selectifyConfigurationItemRelation()
})
