jQuery.extend(  
  jQuery.expr[':'], {  
    contains : "jQuery(a).text().toUpperCase().indexOf(m[3].toUpperCase())>=0"  
});

$(document).ready(function(){
  $("#loot").tablesorter(); 
  $("#toon_filter").keyup(filter_loot);
  $("#item_filter").keyup(filter_loot);
  $("#raid_filter").change(filter_loot);
  $("#primary_filter").change(filter_loot);
  $("#secondary_filter").change(filter_loot);
  load_filters_from_cookie();
  filter_loot();
});

reset_filters = function(){
  $('#toon_filter').val('');
  $('#item_filter').val('');
  $('#raid_filter').val('all');
  $('#primary_filter').attr('checked', true);
  $('#secondary_filter').attr('checked', false);
  filter_loot();
}

load_filters_from_cookie = function(){
  $('#toon_filter').val($.cookie('toon_filter') || '');
  $('#item_filter').val($.cookie('item_filter') || '');
  $('#raid_filter').val($.cookie('raid_filter') || 'all');
  $('#primary_filter').attr('checked', ($.cookie('primary_filter') == 'unchecked') ? false : true);
  $('#secondary_filter').attr('checked', ($.cookie('secondary_filter') == 'unchecked') ? false : true);
}

filter_loot = function(){
  toons = $("#toon_filter").val().toLowerCase().split(" ");
  items = $("#item_filter").val().toLowerCase().split(" ");
  raid = $("#raid_filter option:selected").val();
  if ($("#toon_filter").val() == "" && $("#item_filter").val() == "") {
    $(".filterable tr").show();
  } else {
    if ($("#toon_filter").val() != "") {
      $(".filterable tr:visible").hide();
      $.each(toons, function(){
        if (this.length > 2) {
          $(".filterable tr:hidden .toon_name:contains('" + this + "')").parent().show();
        }
      });
    } else {
      $(".filterable tr:hidden").show();
    }
    $.each(items, function(){
      if (this.length > 2) {
        $(".filterable tr:visible .item_name:not(:contains('" + this + "'))").parent().hide();
      }
    });
  }
  if (raid != "all") {
    $(".filterable tr:visible .raid_id:not(:contains('" + raid + "'))").parent().hide();
  }
  if (!$('#primary_filter').attr('checked')) {
    $(".filterable tr:visible .priority:contains('Primary')").parent().hide();
  }
  if (!$('#secondary_filter').attr('checked')) {
    $(".filterable tr:visible .priority:contains('Secondary')").parent().hide();
  }
  $.cookie('toon_filter', $("#toon_filter").val());
  $.cookie('item_filter', $("#item_filter").val());
  $.cookie('raid_filter', $("#raid_filter").val());
  $.cookie('primary_filter', $("#primary_filter").attr('checked') ? 'checked' : 'unchecked');
  $.cookie('secondary_filter', $("#secondary_filter").attr('checked') ? 'checked' : 'unchecked');
}
