---
layout: post
title: Locate buses on a route 
slug: route_locations
category: bus
---

Get the locations of buses along a bus route. 

Route Locations endpoint: `https://api.umd.io/v0/bus/routes/:route_id/locations`

*Returns*: Predicted arrivals for a stop on the route. 

<!-- EXAMPLE -->
**Sample Request**

`GET https://api.umd.io/v0/bus/routes/115/locations`

Trimmed Response:
{% highlight json%}
  {
"vehicle": [
{
"id": "36",
"lon": "-76.94308",
"routeTag": "115",
"predictable": "true",
"speedKmHr": "7",
"dirTag": "loop",
"heading": "268",
"lat": "38.98756",
"secsSinceReport": "18"
},
{
"id": "31",
"lon": "-76.94943",
"routeTag": "115",
"predictable": "true",
"speedKmHr": "22",
"dirTag": "loop",
"heading": "0",
"lat": "38.99115",
"secsSinceReport": "6"
},
{
"id": "33",
"lon": "-76.9401199",
"routeTag": "115",
"predictable": "true",
"speedKmHr": "5",
"dirTag": "loop",
"heading": "177",
"lat": "38.98465",
"secsSinceReport": "2"
}
],
"lastTime": {
"time": "1428718998722"
},
"copyright": "All data copyright University of Maryland 2015.",
"Error": {
"content": "last time \"t\" parameter must be specified in query string",
"shouldRetry": "false"
}
}
{% endhighlight%}

<!-- END -->