$(document).ready(function(){  
  //add index column with all content.  
  $(".filterable tr:has(td)").each(function(){  
    var t = $(this).text().toLowerCase(); //all row text  
    $("<td class='indexColumn'></td>").hide().text(t).appendTo(this);  
  });//each tr  
  $("#filter_box").keyup(function(){  
      var s = $(this).val().toLowerCase().split(" ");  
      //show all rows.  
      $(".filterable tr:visible").hide();  
      $.each(s, function(){  
        $(".filterable tr:hidden .indexColumn:contains('"  
          + this + "')").parent().show();  
      });//each  
  });//key up.  
});//document.ready
