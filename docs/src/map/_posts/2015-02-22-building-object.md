---
layout: post
title: The building object
slug: building_object
category: map
---

The building object represents the location of a single building. The properties of a building are:

`name` -- name of the building. 

`code` -- Some buildings have codes.

`number` -- unique building number. When you are getting a building, you append its number to the buildings url.

`lng` -- longitude of the building. 

`lat` -- latitude of the building. 

<!-- EXAMPLE -->
**Sample building object**

{% highlight json %}
{
  "name": "251 North",
  "code": "",
  "number": "251",
  "lng": "-76.9496090325357",
  "lat": "38.99274005"
}
{% endhighlight %}

<!-- END -->
