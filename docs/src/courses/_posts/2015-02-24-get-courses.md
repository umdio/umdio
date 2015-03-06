---
layout: post
title: Get courses
slug: get_courses
category: courses
---

Get information about a single course or multiple courses. 

To get data about a single course, append the `course_id` to the courses root URL. 

Example: GET `http://api.umd.io/v0/courses/ENES100`

Returns: The [course object](#course_object) specified, or `null`

To get data about multiple courses, append comma-separated `course_id`s to the courses root URL.

Example: GET `http://api.umd.io/v0/courses/ENES100,CHEM135,CMSC131`

Returns: Array of specified course objects. If one of the course objects does not exist, the rest are still returned.

<!-- EXAMPLE -->
**Sample Request and Response**

Request: GET `http://api.umd.io/v0/courses/ENES100`

Response: `{"course_id":"ENES100","name":"Introduction to Engineering Design","dept_id":"ENES","department":"Engineering Science","semester":"201501","credits":"3","grading_method":["Regular","Pass-Fail","Audit"],"core":["PS"],"gen_ed":["DSSP"],"description":"Corequisite: MATH140.Students work as teams to design and build a product using computer software for word-processing, spreadsheet, CAD, and communication skills.","relationships":{"coreqs":["Corequisite: MATH140"],"prereqs":[],"restrictions":[],"restricted_to":[],"credit_only_granted_for":[],"credit_granted_for":[],"formerly":[],"also_offered_as":[]},"sections":["ENES100-0101","ENES100-0201","ENES100-0202","ENES100-0301","ENES100-0302","ENES100-0401","ENES100-0501","ENES100-0502","ENES100-0601","ENES100-0602","ENES100-0801"]}`
<!-- END -->