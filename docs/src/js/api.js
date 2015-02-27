// for more info see: https://highlightjs.org/usage/
hljs.initHighlightingOnLoad();

$(document).ready(function(){
  $('#menu').stick_in_parent({parent: '#docs'});
  
  // toggle active menu classes on click
  $items = $('#menu').find('ul.active:first li');
  for (var i=0, n=$items.length; i<n; i++) {
    (function(item){
      item.children('a').click(function(e){
        $items.removeClass('active');
        item.addClass('active');
      });
    })( $($items[i]) );
  };
  
  /*$('#languages').stick_in_parent();
  // language toogle active class
  $languages = $('#languages a');
  for (var i=0, n=$languages.length; i<n; i++) {
    $($languages[i]).click(function(e){
      $languages.removeClass('active');
      $(e.target).addClass('active');
    });
  };*/
});

/*
 Sticky-kit v1.1.1 | WTFPL | Leaf Corcoran 2014 | http://leafo.net
*/
(function(){var k,e;k=this.jQuery||window.jQuery;e=k(window);k.fn.stick_in_parent=function(d){var v,y,n,p,h,C,s,G,q,H;null==d&&(d={});s=d.sticky_class;y=d.inner_scrolling;C=d.recalc_every;h=d.parent;p=d.offset_top;n=d.spacer;v=d.bottoming;null==p&&(p=0);null==h&&(h=void 0);null==y&&(y=!0);null==s&&(s="is_stuck");null==v&&(v=!0);G=function(a,d,q,z,D,t,r,E){var u,F,m,A,c,f,B,w,x,g,b;if(!a.data("sticky_kit")){a.data("sticky_kit",!0);f=a.parent();null!=h&&(f=f.closest(h));if(!f.length)throw"failed to find stick parent";
u=m=!1;(g=null!=n?n&&a.closest(n):k("<div />"))&&g.css("position",a.css("position"));B=function(){var c,e,l;if(!E&&(c=parseInt(f.css("border-top-width"),10),e=parseInt(f.css("padding-top"),10),d=parseInt(f.css("padding-bottom"),10),q=f.offset().top+c+e,z=f.height(),m&&(u=m=!1,null==n&&(a.insertAfter(g),g.detach()),a.css({position:"",top:"",width:"",bottom:""}).removeClass(s),l=!0),D=a.offset().top-parseInt(a.css("margin-top"),10)-p,t=a.outerHeight(!0),r=a.css("float"),g&&g.css({width:a.outerWidth(!0),
height:t,display:a.css("display"),"vertical-align":a.css("vertical-align"),"float":r}),l))return b()};B();if(t!==z)return A=void 0,c=p,x=C,b=function(){var b,k,l,h;if(!E&&(null!=x&&(--x,0>=x&&(x=C,B())),l=e.scrollTop(),null!=A&&(k=l-A),A=l,m?(v&&(h=l+t+c>z+q,u&&!h&&(u=!1,a.css({position:"fixed",bottom:"",top:c}).trigger("sticky_kit:unbottom"))),l<D&&(m=!1,c=p,null==n&&("left"!==r&&"right"!==r||a.insertAfter(g),g.detach()),b={position:"",width:"",top:""},a.css(b).removeClass(s).trigger("sticky_kit:unstick")),
y&&(b=e.height(),t+p>b&&!u&&(c-=k,c=Math.max(b-t,c),c=Math.min(p,c),m&&a.css({top:c+"px"})))):l>D&&(m=!0,b={position:"fixed",top:c},b.width="border-box"===a.css("box-sizing")?a.outerWidth()+"px":a.width()+"px",a.css(b).addClass(s),null==n&&(a.after(g),"left"!==r&&"right"!==r||g.append(a)),a.trigger("sticky_kit:stick")),m&&v&&(null==h&&(h=l+t+c>z+q),!u&&h)))return u=!0,"static"===f.css("position")&&f.css({position:"relative"}),a.css({position:"absolute",bottom:d,top:"auto"}).trigger("sticky_kit:bottom")},
w=function(){B();return b()},F=function(){E=!0;e.off("touchmove",b);e.off("scroll",b);e.off("resize",w);k(document.body).off("sticky_kit:recalc",w);a.off("sticky_kit:detach",F);a.removeData("sticky_kit");a.css({position:"",bottom:"",top:"",width:""});f.position("position","");if(m)return null==n&&("left"!==r&&"right"!==r||a.insertAfter(g),g.remove()),a.removeClass(s)},e.on("touchmove",b),e.on("scroll",b),e.on("resize",w),k(document.body).on("sticky_kit:recalc",w),a.on("sticky_kit:detach",F),setTimeout(b,
0)}};q=0;for(H=this.length;q<H;q++)d=this[q],G(k(d));return this}}).call(this);

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