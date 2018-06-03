---
layout: post
title: Searching professors
slug: search
category: professors
---

`https://api.umd.io/v0/professors`

*Returns:* a [Paginated](/#pagination) array of [Professor objects](#professor_object).

----

### Parameters:

`sort` -- specify the field to sort professors by. Professors can either be sorted by `name` or `departments`. Defaults to ASCENDING order, use a `-` prefix to sort by DESCENDING order. For example, `?sort=-departments` will sort by departments in DESCENDING order.

To **search** for professors, each property can be used as a parameter. For example, to search for all professors in the `CMSC` department in the Spring of 2016, the query would look like `?semester=201601&departments=CMSC`. Separate values by commas to search for multiple values for a specific field.

*See the [Professor object](/#professor_object) for a full list of available properties.*

<!-- EXAMPLE -->

Request: `GET https://api.umd.io/v0/professors?department=CMSC,BMGT&sort=-name`
Trimmed Response:
{% highlight json %}
[
  {
    "name": "Zhi-Long Chen",
    "semester": "201608",
    "courses": [
      "BMGT838R",
      "BUDT758R",
      "BUSI788C",
      "BUSM778C"
    ],
    "departments":[
      "BMGT",
      "BUDT",
      "BUSI",
      "BUSM"
    ]
  },
  {
    "name": "Zeinab Karake",
    "semester": "201608",
    "courses":[
      "BMGT301",
      "BMGT301F"
    ],
    "departments":[
      "BMGT"
    ]
  }
  ...
]
{% endhighlight %}

<!-- END -->
