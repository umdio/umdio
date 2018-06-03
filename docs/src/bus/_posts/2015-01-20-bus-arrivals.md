---
layout: post
title: Get predicted arrivals 
slug: arrivals
category: bus
---

Get the predicted arrivals for a particular stop on a route.

Arrivals endpoint: `https://api.umd.io/v0/bus/routes/:route_id/arrivals/:stop_id`

*Returns*: Predicted arrivals for a stop on the route. 


<!-- EXAMPLE -->
**Sample Request**

`GET https://api.umd.io/v0/bus/routes/701/arrivals/greefaye`

Trimmed Response:
{% highlight json%}
{
  "predictions": {
    "agencyTitle": "University of Maryland",
    "routeTag": "701",
    "routeTitle": "701 UMB BioPark",
    "direction": {
      "title": "Ramsay St Apts",
      "prediction": [
        {
        "isDeparture": "false",
        "minutes": "3",
        "seconds": "194",
        "vehicle": "66",
        "affectedByLayover": "true",
        "block": "7011",
        "dirTag": "ramsapts",
        "epochTime": "1428953061631"
        },
        {
        "isDeparture": "false",
        "minutes": "42",
        "seconds": "2523",
        "vehicle": "66",
        "affectedByLayover": "true",
        "block": "7011",
        "dirTag": "ramsapts",
        "epochTime": "1428955390195"
        },
        {
        "isDeparture": "false",
        "minutes": "82",
        "seconds": "4923",
        "vehicle": "66",
        "affectedByLayover": "true",
        "block": "7011",
        "dirTag": "ramsapts",
        "epochTime": "1428957790195"
        }
      ]
    },
    "stopTitle": "Green St & Fayette St",
    "stopTag": "greefaye"
  },
"copyright": "All data copyright University of Maryland 2015."
}
{% endhighlight%}

<!-- END -->