---
layout: post
title: Get buildings
slug: get_buildings
category: map
---

Get location data about one or more buildings. Comma separated building numbers are the parameters.

`https://api.umd.io/v0/map/buildings/:building_number`

*Returns*: A list of complete [building objects](#building_object).

<!-- EXAMPLE -->
**Get Buildings**

GET `https://api.umd.io/v0/map/buildings/251`

returns
{% highlight json%}
{
  "name": "251 North",
  "code": "",
  "number": "251",
  "lng": "-76.9496090325357",
  "lat": "38.99274005"
}
{% endhighlight %}
<!-- END -->