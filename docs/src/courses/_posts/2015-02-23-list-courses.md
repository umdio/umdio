---
layout: post
title: List all courses
slug: list_courses
category: courses
---

There are two ways to list all of the available courses at the university. To list the full course objects:

`http://api.umd.io/v0/courses`

*Returns:* Array of full course objects.

For a faster, cleaner, less memory-intensive list:

`http://api.umd.io/v0/courses/list`

*Returns:* Array of objects with three properties: `course_id`, `name`, and `department`

<!-- EXAMPLE -->

Request: `GET http://api.umd.io/v0/courses`
{% highlight json %}
[
  <Course object>,
  <Course object>,
  ...
]
{% endhighlight %}

Request: `GET http://api.umd.io/v0/courses/list`
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
  },
  ...
]
{% endhighlight %}

<!-- END -->