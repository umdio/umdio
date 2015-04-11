---
layout: post
title: List all courses
slug: list_courses
category: courses
---

List all the courses available.

`http://api.umd.io/v0/courses`

*Returns:* Array of objects with three properties: `course_id`, `name`, and `department`

----

### Parameters:

`sort` -- a comma-separated list of course properties. Defaults to ASCENDING order, use a `-` (minus) prefix for DESCENDING order.
<br>For example, `?sort=course_id,-credits` would sort results ASCENDING by course_id and DESCENDING by credits.

`search` -- to search the format is `<course_property><comparision><value>`. Use each course property as a new query argument and one of the following comparisions `=` (equals), `<` (less than), `>` (greater than), `<=` (less than or equals) and `>=` (greater than or equals) followed by the value.
<br>For example, `?dept_id=CMSC&credits<=1` would give all courses in the CMSC department with less than or equal to 1 credit.

*See the [Course object](/#course_object) for a full list of available properties.*

<!-- EXAMPLE -->

Request: `GET http://api.umd.io/v0/courses`
Trimmed Response:
{% highlight json %}
[
  {
    "course_id": "AASP100",
    "name": "Introduction to African American Studies",
    "department": "African American Studies"
  },
  {
    "course_id": "AASP101",
    "name": "Public Policy and the Black Community",
    "department":"African American Studies"
  }
]
{% endhighlight %}

<!-- END -->
