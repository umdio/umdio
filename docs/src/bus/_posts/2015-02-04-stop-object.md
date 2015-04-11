---
layout: post
title: Stop object
slug: stop_object
category: bus
---

The stop object represents a bus stop.

It has 

`stop_id` -- unique string identifier for a stop, like 'laplat'. NextBus came up with these names, and most of the time, you can decipher what stop they mean. 'laplat' is the Laplata Hall stop. 'guilrowa_out' is Guilford Drive and Rowalt Drive (Outbound). 

`title` -- the full name of the stop.

`lon` -- longitude of the stop

`lat` -- latitude of the stop

<!-- EXAMPLE -->
**Sample Object**

{% highlight json%}
  {
  "stop_id": "laplat",
  "title": "La Plata Hall",
  "lon": "-76.94563",
  "lat": "38.9922185"
}
{% endhighlight%}

<!-- END -->