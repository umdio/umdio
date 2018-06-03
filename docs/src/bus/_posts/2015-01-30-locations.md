---
layout: post
title: Get bus locations
slug: locations
category: bus
---

Get locations of all the umd buses. 

----

`https://api.umd.io/v0/bus/locations`

*Returns*: Object with several properties - meta information and the list of locations for vehicles.

<!-- EXAMPLE -->
**Sample Request**

`GET https://api.umd.io/v0/bus/locations`

Trimmed Response:
{% highlight json%}
{
"vehicle": [
{
"id": "66",
"lon": "-76.61603",
"routeTag": "702",
"predictable": "true",
"speedKmHr": "3",
"dirTag": "charpenn",
"heading": "106",
"lat": "39.28906",
"secsSinceReport": "4"
},
{
"id": "76",
"lon": "-76.9323299",
"routeTag": "122",
"predictable": "true",
"speedKmHr": "37",
"dirTag": "leoncomm",
"heading": "319",
"lat": "38.9839399",
"secsSinceReport": "15"
}],
"lastTime": {
"time": "1428715950117"
},
"copyright": "All data copyright University of Maryland 2015.",
"Error": {
"content": "last time \"t\" parameter must be specified in query string",
"shouldRetry": "false"
}
}
{% endhighlight%}

<!-- END -->