---
layout: page
title: Bus
permalink: /bus/
category: bus
slug: bus
---

This endpoint lets you get data about bus routes, schedules, stops, locations, and predicted arrival times. The data is provided by [NextBus](http://www.dots.umd.edu/nextbus.html), which monitors buses and gives the data to us via their [API](http://webservices.nextbus.com/service/publicJSONFeed?a=umd). We think our API is easier to use, but our data might be behind NextBus by a few seconds. If your app requires to-the-second bus location info, you can go right to the source.

All bus data is copyright University of Maryland 2015.

<!-- EXAMPLE -->

### Bus Endpoint

`https://api.umd.io/v0/bus`

<!-- END -->