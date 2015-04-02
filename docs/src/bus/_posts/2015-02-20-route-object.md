---
layout: post
title: The route object
slug: route_object
category: bus
---

The route object represents a bus route. The properties of a route are:

`route_id` -- a unique three digit route number. Examples: *"115", "701"*.

`title` -- string name of the route. Examples: *"115 Orange", "701 UMB BioPark"*

`stops` -- Array of bus stops on a route. Stops have a unique string `stop_id`, a full `title`, and `lon` (longitude) and `lat` (latitude) coordinates. Routes have a lot of stops, so this might look a little messy.

`directions` -- Array of directions the bus travels. A direction has a unique string `direction_id`, a `title`, and an array of `stops` specifying the stops along the route in that direction. Many buses only have one direction, 'loop' , which has all stops on the route. Otherwise, there are usually two directions, mostly named for the final stop in that direction.

`paths` -- When you want to draw the route on the map, you use the *paths*. These are several arrays (an array of arrays) of latitude and longitude coordinates (points). According to NextBus, connect the points in array separately, and you will end up with a nice outline of the route. Don't try to connect the points between the arrays of points, because they won't match up. There are a lot of points (a few hundred) for each route. 

The next four are useful if you are trying to fit the route in a map window.

`lat_max` -- Maximum latitude of the bus route. 

`lat_min` -- Minimum latitude of the bus route.

`lon_max` -- Maximum longitude of the bus route.

`lon_min` -- Minimum longitude of the bus route.

<!-- EXAMPLE -->
**Sample route object**
(trimmed for space - there are more stops and path data)
{% highlight json %}
  {"route_id":"115",
  "title":"115 Orange",  
  "stops":
  [

    {"stop_id":"lot1",
    "title":"Union Dr at Lot 1b",
    "lon":"-76.9481576",
    "lat":"38.9872099"},

    {"stop_id":"cspac",
    "title":"Valley Drive at Stadium Drive Garage",
    "lon":"-76.949374",
    "lat":"38.990882"},
  ],
  "directions":[{
    "direction_id":"loop",
    "title":"Loop",
    "stops":["lot1",
      "cspac",
      "elk",
      "hage",
      "laplat",
      "camb",
      "regegara_d"]
    }],
  "paths":[
  [
    {"lon":"-76.9432099","lat":"38.98756"},
    {"lon":"-76.943614","lat":"38.987555"},
    {"lon":"-76.943945","lat":"38.9876099"}
  ],
  [
    {"lon":"-76.93915","lat":"38.98243"},
    {"lon":"-76.93908","lat":"38.9824"},
    {"lon":"-76.93877","lat":"38.98232"},
    {"lon":"-76.93867","lat":"38.9823"},
    {"lon":"-76.93855","lat":"38.98228"},
    {"lon":"-76.93838","lat":"38.98225"},
    {"lon":"-76.93818","lat":"38.9822"},
    {"lon":"-76.93797","lat":"38.98215"},
    {"lon":"-76.93791","lat":"38.98216"},
    {"lon":"-76.93787","lat":"38.9822"},
    {"lon":"-76.93786","lat":"38.9822599"}]
  ],
  "lat_max":"38.99297",
  "lat_min":"38.9824312",
  "lon_max":"-76.9370967",
  "lon_min":"-76.949374"
  }
{% endhighlight %}

<!-- END -->
