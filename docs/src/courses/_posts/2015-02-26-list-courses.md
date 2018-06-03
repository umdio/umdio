---
layout: post
title: List all courses
slug: list_courses
category: courses
---

List all the courses available (for the given semester, or the current semester by default).

`https://api.umd.io/v0/courses/list`

*Returns:* Array of objects with three properties: `course_id`, `name`, and `department`

<!-- EXAMPLE -->

Request: `GET https://api.umd.io/v0/courses/list`
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
