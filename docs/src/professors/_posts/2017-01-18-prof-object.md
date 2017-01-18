---
layout: post
title: The professor object
slug: professor_object
category: professors
---

The professor object represents a UMD professor. The properties of a professor are:

`name` -- the name of a professor as it appears on Testudo..

`course` -- An array of courses that the professor has taught in the given semester.

`department` -- An array of the departments a professor has taught in the given semester.

`semester` -- Six-digit number identifying the semester the course is offered. 


<!-- EXAMPLE -->
**Sample professor object**
{% highlight json %}
{
  "name": "Mark Wellman",
  "semester": "201608",
  "course": [
    "BMGT289B",
    "BMGT466",
    "CPBE225"
  ],
  "department": [
    "BMGT",
    "CPBE"
  ]
}
{% endhighlight %}

<!-- END -->