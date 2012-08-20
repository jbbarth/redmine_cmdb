jQuery(function($) {
  window.selectifyConfigurationItemRelation = function() {
    $("#relation_configuration_item_id").select2({
      minimumInputLength: 1,
      multiple: true,
      ajax: { // instead of writing the function to execute the request we use Select2's convenient helper
        url: '../../configuration_items.json',
        dataType: 'json',
        data: function (term, page) {
          return { search: term, limit: 10, not: $("#relation_configuration_item_id").data("currentIds") }
        },
        results: function (data, page) {
          result = { results: [] }
          $.each(data.configuration_items, function() {
            result.results.push({id: this.id, text: this.name})
          })
          return result
        }
      },
      formatInputTooShort: function() { return "" },
      formatSearching: function() { return "..." },
      formatNoMatches: function() { return $("#relation_configuration_item_id").data("noMatches") },
      formatResult: function(e) { return e.text },
      containerCssClass: 'configuration-items-select2',
      zformatSelection: function() { },
      zdropdownCssClass: "bigdrop"
    });
  }
  selectifyConfigurationItemRelation()
})
