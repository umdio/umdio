---
layout: post
title: Searching courses
slug: search
category: courses
---

`https://api.umd.io/v0/courses`

*Returns:* a [Paginated](/#pagination) array of [Course objects](#course_object).

----

### Parameters:

`sort` -- a comma-separated list of course properties. Defaults to ASCENDING order, use a `-` (minus) prefix for DESCENDING order.
<br>For example, `?sort=course_id,-credits` sorts the results ASCENDING by course_id and DESCENDING by credits.

To **search** for courses, use each course property as a parameter and one of the following comparisions: `=` (equals), `!=` (not equals), `<` (less than), `>` (greater than), `<=` (less than or equals) and `>=` (greater than or equals) followed by the value or a list of values.
<br>For example, `?dept_id=CMSC,BMGT&credits<2` gives all courses in the CMSC or BMGT departments worth less than 2 credits.

*See the [Course object](/#course_object) for a full list of available properties.*

-----

When searching array properties, the `|` (pipe) delimeter may be used instead of a comma to only return results that all the values.
<br>For example, `?grading_method=Audit|Pass-Fail` gives all courses whose grading method is both Audit and Pass-Fail.

<!-- EXAMPLE -->

Request: `GET https://api.umd.io/v0/courses?dept_id=CMSC,BMGT&credits<2`
Trimmed Response:
{% highlight json %}
[
  {
    "course_id": "BMGT888W",
    "name": "Special Topics in Supply Chain Management; Workshop in Supply Chain Management",
    "dept_id": "BMGT",
    "credits": "1",
    ...
    "sections": [
      "BMGT888W-0101",
      "BMGT888W-0101"
    ]
  },
  {
    "course_id": "CMSC100",
    "name": "Bits and Bytes of Computer Science",
    "dept_id": "CMSC",
    "credits": "1",
    ...
    "sections": [
      "CMSC100-0101",
      "CMSC100-0101"
    ]
  }
  ...
]
{% endhighlight %}

<!-- END -->
