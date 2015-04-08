// for more info see: https://highlightjs.org/usage/
hljs.initHighlightingOnLoad();

$(document).ready(function(){
  var $menu = $('#menu');
  
  var resize = function(){
    $menu.css('width', $menu.parent().css('width'));
  };
  $(window).resize(resize);
  resize();
  
  $menu.affix({
    offset: {
      top: 0,
      bottom: function() {
        return -($('#docs').outerHeight(true) - $('body').outerHeight(true));
      }
    }
  });
  
  // toggle active menu classes on click
  $items = $menu.find('ul.active:first li');
  for (var i=0, n=$items.length; i<n; i++) {
    (function(item){
      item.children('a').click(function(e){
        $items.removeClass('active');
        item.addClass('active');
      });
    })( $($items[i]) );
  };
  
  // mobile menu toggle
  var toggle = document.getElementById('toggle');
  toggle.addEventListener('click', function() {
    $('body').toggleClass('active');
  });

  // fix external links
  var pageContent = document.getElementById('docs');
  var links = pageContent.getElementsByTagName('a');
  for (var i=0,n=links.length; i<n; i++) {
    if (links[i].href.substr(0, 4) == 'http' && links[i].origin != window.location.origin) {
      links[i].target = "_blank";
    }
  }
});

/* ========================================================================
 * Bootstrap: scrollspy.js v3.3.2 - edited (.nav -> nav)
 * http://getbootstrap.com/javascript/#scrollspy
 * ========================================================================
 * Copyright 2011-2015 Twitter, Inc.
 * Licensed under MIT (https://github.com/twbs/bootstrap/blob/master/LICENSE)
 * ======================================================================== */
+function(b){function c(a,h){var g=b.proxy(this.process,this);this.$body=b("body");this.$scrollElement=b(a).is("body")?b(window):b(a);this.options=b.extend({},c.DEFAULTS,h);this.selector=(this.options.target||"")+" nav li > a";this.offsets=[];this.targets=[];this.activeTarget=null;this.scrollHeight=0;this.$scrollElement.on("scroll.bs.scrollspy",g);this.refresh();this.process()}function l(a){return this.each(function(){var h=b(this),g=h.data("bs.scrollspy"),d="object"==typeof a&&a;g||h.data("bs.scrollspy",
g=new c(this,d));if("string"==typeof a)g[a]()})}c.VERSION="3.3.2";c.DEFAULTS={offset:10};c.prototype.getScrollHeight=function(){return this.$scrollElement[0].scrollHeight||Math.max(this.$body[0].scrollHeight,document.documentElement.scrollHeight)};c.prototype.refresh=function(){var a="offset",c=0;b.isWindow(this.$scrollElement[0])||(a="position",c=this.$scrollElement.scrollTop());this.offsets=[];this.targets=[];this.scrollHeight=this.getScrollHeight();var g=this;this.$body.find(this.selector).map(function(){var d=
b(this),d=d.data("target")||d.attr("href"),e=/^#./.test(d)&&b(d);return e&&e.length&&e.is(":visible")&&[[e[a]().top+c,d]]||null}).sort(function(a,b){return a[0]-b[0]}).each(function(){g.offsets.push(this[0]);g.targets.push(this[1])})};c.prototype.process=function(){var a=this.$scrollElement.scrollTop()+this.options.offset,b=this.getScrollHeight(),c=this.options.offset+b-this.$scrollElement.height(),d=this.offsets,e=this.targets,k=this.activeTarget,f;this.scrollHeight!=b&&this.refresh();if(a>=c)return k!=
(f=e[e.length-1])&&this.activate(f);if(k&&a<d[0])return this.activeTarget=null,this.clear();for(f=d.length;f--;)k!=e[f]&&a>=d[f]&&(!d[f+1]||a<=d[f+1])&&this.activate(e[f])};c.prototype.activate=function(a){this.activeTarget=a;this.clear();a=b(this.selector+'[data-target="'+a+'"],'+this.selector+'[href="'+a+'"]').parents("li").addClass("active");a.parent(".dropdown-menu").length&&(a=a.closest("li.dropdown").addClass("active"));a.trigger("activate.bs.scrollspy")};c.prototype.clear=function(){b(this.selector).parentsUntil(this.options.target,
".active").removeClass("active")};var m=b.fn.scrollspy;b.fn.scrollspy=l;b.fn.scrollspy.Constructor=c;b.fn.scrollspy.noConflict=function(){b.fn.scrollspy=m;return this};b(window).on("load.bs.scrollspy.data-api",function(){b('[data-spy="scroll"]').each(function(){var a=b(this);l.call(a,a.data())})})}(jQuery);

/* ========================================================================
 * Bootstrap: affix.js v3.3.4
 * http://getbootstrap.com/javascript/#affix
 * ========================================================================
 * Copyright 2011-2015 Twitter, Inc.
 * Licensed under MIT (https://github.com/twbs/bootstrap/blob/master/LICENSE)
 * ======================================================================== */
+function(b){function k(e){return this.each(function(){var a=b(this),d=a.data("bs.affix"),g="object"==typeof e&&e;d||a.data("bs.affix",d=new c(this,g));if("string"==typeof e)d[e]()})}var c=function(e,a){this.options=b.extend({},c.DEFAULTS,a);this.$target=b(this.options.target).on("scroll.bs.affix.data-api",b.proxy(this.checkPosition,this)).on("click.bs.affix.data-api",b.proxy(this.checkPositionWithEventLoop,this));this.$element=b(e);this.pinnedOffset=this.unpin=this.affixed=null;this.checkPosition()};
c.VERSION="3.3.4";c.RESET="affix affix-top affix-bottom";c.DEFAULTS={offset:0,target:window};c.prototype.getState=function(b,a,d,c){var f=this.$target.scrollTop(),h=this.$element.offset(),k=this.$target.height();if(null!=d&&"top"==this.affixed)return f<d?"top":!1;if("bottom"==this.affixed)return null!=d?f+this.unpin<=h.top?!1:"bottom":f+k<=b-c?!1:"bottom";var l=null==this.affixed,h=l?f:h.top;return null!=d&&f<=d?"top":null!=c&&h+(l?k:a)>=b-c?"bottom":!1};c.prototype.getPinnedOffset=function(){if(this.pinnedOffset)return this.pinnedOffset;
this.$element.removeClass(c.RESET).addClass("affix");var b=this.$target.scrollTop();return this.pinnedOffset=this.$element.offset().top-b};c.prototype.checkPositionWithEventLoop=function(){setTimeout(b.proxy(this.checkPosition,this),1)};c.prototype.checkPosition=function(){if(this.$element.is(":visible")){var e=this.$element.height(),a=this.options.offset,d=a.top,g=a.bottom,f=b(document.body).height();"object"!=typeof a&&(g=d=a);"function"==typeof d&&(d=a.top(this.$element));"function"==typeof g&&
(g=a.bottom(this.$element));a=this.getState(f,e,d,g);if(this.affixed!=a){null!=this.unpin&&this.$element.css("top","");var d="affix"+(a?"-"+a:""),h=b.Event(d+".bs.affix");this.$element.trigger(h);if(h.isDefaultPrevented())return;this.affixed=a;this.unpin="bottom"==a?this.getPinnedOffset():null;this.$element.removeClass(c.RESET).addClass(d).trigger(d.replace("affix","affixed")+".bs.affix")}"bottom"==a&&this.$element.offset({top:f-e-g})}};var m=b.fn.affix;b.fn.affix=k;b.fn.affix.Constructor=c;b.fn.affix.noConflict=
function(){b.fn.affix=m;return this};b(window).on("load",function(){b('[data-spy="affix"]').each(function(){var c=b(this),a=c.data();a.offset=a.offset||{};null!=a.offsetBottom&&(a.offset.bottom=a.offsetBottom);null!=a.offsetTop&&(a.offset.top=a.offsetTop);k.call(c,a)})})}(jQuery);
