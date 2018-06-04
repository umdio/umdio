---
layout: post
title: Get courses
slug: get_courses
category: courses
---

Get information about one or more courses.

----

`https://api.umd.io/v0/courses/<course_id>`

Get information about one course.

*Returns:* The [course object](#course_object) specified, or a 404 error, letting you know that the course doesn't exist on the database.

----

`https://api.umd.io/v0/courses/<course_ids>`

Get information about multiple courses where `course_ids` is a comma-seperated list of `course_id`'s.

*Returns:* Array of [course objects](#course_object). If one of the course objects does not exist, the rest are still returned.

<!-- EXAMPLE -->
**Sample Request**

`GET https://api.umd.io/v0/courses/ENES100`

Response:
{% highlight json %}
{
  "course_id": "ENES100",
  "name": "Introduction to Engineering Design",
  "dept_id":"ENES",
  "department": "Engineering Science",
  "semester": "201501",
  "credits": "3",
  "grading_method": ["Regular", "Pass-Fail", "Audit"],
  "core": ["PS"],
  "gen_ed": ["DSSP"],
  "description": "Students work as teams to design...",
  "relationships": {
    "coreqs": ["Corequisite: MATH140"]
  },
  "sections": [
    "ENES100-0101",
    "ENES100-0201",
    "ENES100-0202",
    "ENES100-0301",
    "ENES100-0302",
    "ENES100-0401",
    "ENES100-0501",
    "ENES100-0502",
    "ENES100-0601",
    "ENES100-0602",
    "ENES100-0801"
  ]
}
{% endhighlight %}
<!-- END -->