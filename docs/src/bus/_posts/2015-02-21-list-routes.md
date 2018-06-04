---
layout: post
title: List routes
slug: list_routes
category: bus
---

List all the bus routes. Returns the route ids and the names of the routes.

----

`https://api.umd.io/v0/bus/routes`

*Returns*: Array of the bus routes as JSON Objects with 'route_id' and 'title' fields.

<!-- EXAMPLE -->
**Sample Request**

`GET https://api.umd.io/v0/bus/routes`

Trimmed Response:
{% highlight json%}
[
  {
    "route_id": "109",
    "title": "109 River Road"
  },
  {
    "route_id":"114",
    "title": "University View"
  },
  {
    "route_id":"115",
    "title": "115 Orange"
  }
]

{% endhighlight%}

<!-- END -->