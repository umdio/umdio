---
layout: post
title: Get route schedules
slug: route_schedules
category: bus
---

Get the schedules for a route. 

Each route has multiple schedules, because buses run differently on different days of the week. umdio can't guarantee that the buses will arrive at the scheduled times, but we'll try to get the schedules to you.

----

`https://api.umd.io/v0/bus/routes/:route_id/schedules`

*Returns*: Array of bus schedules for the specified route. 

Each schedule has the days that schedule runs - 'f' for friday, 'th' for tuesday and thursday. Also, the direction of the route, route number, an array of the stops on the schedule, and an array of trips. The stops on the schedule are not all of the stops on the route, just the ones that are scheduled. The trips are each arrays of stops and the times the bus is scheduled to stop, in two formats: arrival_time, which is the [ISO 8601](http://en.wikipedia.org/wiki/ISO_8601) extended time format - hh:mm:ss - and a count of UNIX seconds since the beginning of the day - a number like 21600000, for 6:00 AM. All times are EST, since that's local. 

<!-- EXAMPLE -->
**Sample Request**

`GET https://api.umd.io/v0/bus/routes/115/schedules`

Trimmed Response:
{% highlight json%}
[{
  "days":"f",
  "direction":"ramsapts",
  "route":"701",
  "stops":[{
    "stop_id":"peargara_d",
    "name":"Pearl St Garage"}],
  "trips":[[{
    "stop_id":"peargara_d",
    "arrival_time":"06:00:00",
    "arrival_time_secs":"21600000"}],
    [{"stop_id":"peargara_d",
    "arrival_time":"06:32:00",
    "arrival_time_secs":"23520000"}],
    [{"stop_id":"peargara_d",
    "arrival_time":"07:04:00",
    "arrival_time_secs":"25440000"}],
    [{"stop_id":"peargara_d",
    "arrival_time":"07:38:00",
    "arrival_time_secs":"27480000"}]]
}]
{% endhighlight%}

<!-- END -->