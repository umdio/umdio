---
layout: post
title: Get route schedule
slug: route_schedule
category: bus
---

Get the bus schedule for a particular route. The schedule object is a little complicated, so look at the example and this documentation. For now, we are just sending the unmodified NextBus data. Soon, the data at this endpoint will change and be friendlier to use. For now, you should play around with the api to figure out what's available here.

----

`http://api.umd.io/v0/bus/routes/:route_id/schedule`

*Returns*: Bus schedule object for the specified route. See the sample object. 


<!-- EXAMPLE -->
**Sample Request**

`GET http://api.umd.io/v0/bus/routes/115/schedule`

Trimmed Response:
{% highlight json%}
{
"route": [
  {
    "serviceClass": "f",
    "title": "115 Orange",
    "tr": [],
    "direction": "loop",
    "tag": "115",
    "header": {},
    "scheduleClass": "peak"
  },
  {
  "serviceClass": "mtw",
  "title": "115 Orange",
  "tr": [],
  "direction": "loop",
  "tag": "115",
  "header": {},
  "scheduleClass": "peak"
  }
]
{% endhighlight%}

<!-- END -->