---
layout: post
title: List all courses
slug: list_courses
category: courses
---
There are two ways to list all of the available courses at the university. 

To list the full course objects, GET `http://api.umd.io/v0/courses`. 

Returns: Array of full course objects.

For a cleaner, less memory-intensive list with only the `course_id`, `name`, and `department` of each course, GET `http://api.umd.io/v0/courses/list`. 

Returns: Array of JSON objects with three properties: `course_id`, `name`, and `department`

<!-- EXAMPLE -->
Portion of sample response.

Request: `GET http://api.umd.io/v0/courses/list`

Response: `[{"course_id":"AASP100","name":"Introduction to African American Studies","department":"African American Studies"},{"course_id":"AASP100H","name":"Introduction to African American Studies","department":"African American Studies"},{"course_id":"AASP101","name":"Public Policy and the Black Community","department":"African American Studies"},{"course_id":"AASP200","name":"African Civilization","department":"African American Studies"},{"course_id":"AASP202H","name":"Black Culture in the United States","department":"African American Studies"},...]`

<!-- END -->