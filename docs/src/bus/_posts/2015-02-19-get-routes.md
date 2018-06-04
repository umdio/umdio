---
layout: post
title: Get routes
slug: get_routes
category: bus
---

Get detailed info about one or more bus routes.

----

`https://api.umd.io/v0/bus/routes/<route_id>`

*Returns*: Specified [route object](#route_object).

---
`https://api.umd.io/v0/bus/routes/<route_ids>`

*Returns*: Specified [route objects](#route_object), where `route_ids` is a comma-separated list of route_ids, like `115,118,701`. 


<!-- EXAMPLE -->
**Sample Request**

`GET https://api.umd.io/v0/bus/routes/115`

Trimmed Response:
{% highlight json %}
{
  "route_id": "701",
  "title": "701 UMB BioPark",
  "stops": [],
  "directions": [
    {
      "direction_id": "peargara",
      "title": "Pearl St Garage",
      "stops": []
    },
    {
      "direction_id": "ramsapts",
      "title": "Ramsay St Apts",
      "stops": []
    }
  ],
  "paths": [],
  "lat_max": "39.2995236",
  "lat_min": "39.28301",
  "lon_max": "-76.620848",
  "lon_min": "-76.6320545"
}
{% endhighlight %}

<!-- END -->
