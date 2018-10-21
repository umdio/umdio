// for more info see: https://highlightjs.org/usage/
//hljs.initHighlightingOnLoad();

$(document).ready(function(){
  // var lastId;
  // const header = $(".header");
  // const headerHeight = header.outerHeight() + 1;
  // const menuItems = $(".ref-endpoints").find(".menu-item");
  // var scrollAnchors = menuItems.map(function(){
  //   var item = $($(this).attr('href'));
  //   if (item.length) { return item; }
  // });
  // mobile menu toggle
  $('.btn').click(function(){
    var sidebar = document.getElementById('sidebar');
    $(this).toggleClass("active");
    $(sidebar).toggleClass("active");
  })

  $('.menu-item').click(function(){
    var sidebar = document.getElementById('sidebar');
    var btn = document.getElementById('btn');
    $(btn).toggleClass("active");
    $(sidebar).toggleClass("active");
  })


  //NOT WORKING YET

  // $('.docs').scroll(function(){
  //   var fromTop = $(this).scrollTop();
  //  // Get id of current scroll item
  //   var cur = scrollAnchors.map(function(){
  //     if ($(this).offset().top < fromTop)
  //       return this;
  //   });
  //   // Get the id of the current element
  //   cur = cur[cur.length-1];
  //   var id = cur && cur.length ? cur[0].id : "";
  //   if (lastId !== id) {
  //       lastId = id;
  //   }       
  // })

});