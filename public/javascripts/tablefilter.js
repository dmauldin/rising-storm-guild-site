jQuery.extend(  
  jQuery.expr[':'], {  
    contains : "jQuery(a).text().toUpperCase().indexOf(m[3].toUpperCase())>=0"  
});

$(document).ready(function(){
  $("#loot").tablesorter(); 
  $("#toon_filter").keyup(filter_loot);
  $("#item_filter").keyup(filter_loot);
  filter_loot();
});

filter_loot = function(){
  toons = $("#toon_filter").val().toLowerCase().split(" ");
  items = $("#item_filter").val().toLowerCase().split(" ");
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
}