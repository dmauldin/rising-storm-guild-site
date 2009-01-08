jQuery.extend(  
  jQuery.expr[':'], {  
    contains : "jQuery(a).text().toUpperCase().indexOf(m[3].toUpperCase())>=0"  
});

$(document).ready(function(){
  $("#toon_filter").keyup(filter_loot);
  $("#item_filter").keyup(filter_loot);
  filter_loot();
});

filter_loot = function(){
  toons = $("#toon_filter").val().toLowerCase().split(" ");
  items = $("#item_filter").val().toLowerCase().split(" ");
  $(".filterable tr:visible").hide();
  $.each(toons, function(){
    if (this.length > 2) {
      $(".filterable tr:hidden .toon_name:contains('" + this + "')").parent().show();
    }
  });
  $.each(items, function(){
    if (this.length > 2) {
      $(".filterable tr:visible .item_name:not(:contains('" + this + "'))").parent().hide();
    }
  });
}
