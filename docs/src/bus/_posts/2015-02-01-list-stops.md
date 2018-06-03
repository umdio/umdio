---
layout: post
title: List stops
slug: stops
category: bus
---

Get information about all the stops.

Endpoint: `https://api.umd.io/v0/bus/stops`

*Returns*: Array of stops with stop_id and title.  

<!-- EXAMPLE -->
**Sample Request**

`GET https://api.umd.io/v0/bus/stops`

Trimmed Response:
{% highlight json%}
  [
{
"stop_id": "laplat",
"title": "La Plata Hall"
},
{
"stop_id": "camb",
"title": "Cambridge Hall"
},
{
"stop_id": "guilrowa_out",
"title": "Guilford Drive and Rowalt Drive (Outbound)"
},
{
"stop_id": "guilhart",
"title": "Guilford Drive and Hartwick Road"
},
{
"stop_id": "mowaprei",
"title": "Mowatt Lane and Preinkert Drive"
},
{
"stop_id": "mowagara",
"title": "Mowatt Lane Garage"
},
{
"stop_id": "vanmunch",
"title": "Van Munching Hall (Outbound)"
}
]
{% endhighlight%}

<!-- END -->
