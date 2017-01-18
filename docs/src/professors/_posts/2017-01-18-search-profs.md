---
layout: post
title: Searching professors
slug: search
category: professors
---

`http://api.umd.io/v0/professors`

*Returns:* a [Paginated](/#pagination) array of [Professor objects](#professor_object).

----

### Parameters:

`sort` -- specify the field to sort professors by. Professors can either be sorted by `name` or `department`. Defaults to ASCENDING order, use a `-` prefix to sort by DESCENDING order. For example, `?sort=-department` will sort by departments in DESCENDING order.

To **search** for professors, each property can be used as a parameter. For example, to search for all professors in the `CMSC` department in the Spring of 2016, the query would look like `?semester=201601&department=CMSC`. Separate values by commas to search for multiple values for a specific field.

*See the [Professor object](/#professor_object) for a full list of available properties.*

<!-- EXAMPLE -->

Request: `GET http://api.umd.io/v0/professors?department=CMSC,BMGT&sort=-name`
Trimmed Response:
{% highlight json %}
[
  {
    "name": "Zhi-Long Chen",
    "semester": "201608",
    "course": [
      "BMGT838R",
      "BUDT758R",
      "BUSI788C",
      "BUSM778C"
    ],
    "department":[
      "BMGT",
      "BUDT",
      "BUSI",
      "BUSM"
    ]
  },
  {
    "name": "Zeinab Karake",
    "semester": "201608",
    "course":[
      "BMGT301",
      "BMGT301F"
    ],
    "department":[
      "BMGT"
    ]
  }
  ...
]
{% endhighlight %}

<!-- END -->
