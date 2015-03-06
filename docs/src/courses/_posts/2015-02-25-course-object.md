---
layout: post
title: The course object
slug: course_object
category: courses
---

The course object represents a single UMD course. The properties of a course are:

`course_id` -- a unique string ID with a four-letter `dept_id` followed by a three digit course number and an optional letter. Examples: *"CSMC132", "BMGT468Z"*.

`name` -- string name of the course.

`dept_id` -- Four-letter string like ENGL or BMGT.

`department` -- Full name of the department that offers a course.

`semester` -- Six-digit number identifying the semester the course is offered. Currently, the API only offers courses for the current semester, but that will change soon. 

`credits` -- One-digit number of credits the course is worth.

`grading_method` -- Array of string grading options available. The possible options are *"Regular", "Pass-Fail", "Audit", and "Sat-Fail"*

`core` -- Array of strings of CORE requirements filled by a course.

`gen_ed` -- Array of strings of GEN. ED requirements filled by a course.

`description` -- String description of a course.

`relationships` -- contains the relationships and restrictions of a course which can be: `coreqs`, `prereqs`, `restrictions`, `restricted_to`, `credit_only_granted_for`, `credit_granted_for`,`formerly`, and `also_offered_as`.

`sections` -- Array of `section_id` strings of the sections of a course. See [section object](#section_object).

<!-- EXAMPLE -->
**Sample course object**
{% highlight json %}
{
  "course_id": "ENEE380",
  "name": "Electromagnetic Theory",
  "dept_id": "ENEE",
  "department": "Electrical & Computer Engineering",
  "semester": "201501",
  "credits": "3",
  "grading_method": ["Regular"],
  "core": [],
  "gen_ed": [],
  "description": "Introduction to electromagnetic...",
  "relationships": {
    "coreqs": [],
    "prereqs": ["Prerequisite: PHYS271, PHYS270, ..."],
    "restrictions": [],
    "restricted_to": [],
    "credit_only_granted_for": [],
    "credit_granted_for": [],
    "formerly": [],
    "also_offered_as": []
  },
  "sections": [
    "ENEE380-0101",
    "ENEE380-0102",
    "ENEE380-0103"
  ]
}
{% endhighlight %}

<!-- END -->
