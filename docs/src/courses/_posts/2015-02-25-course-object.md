---
layout: post
title: The course object
slug: course_object
category: courses
---

The course object represents a single UMD course. The properties of a course are:

`course_id`: Courses are identified by their unique ID - like 'ENGL101'. `course_id` is always a string with a four-letter `dept_id` followed by a three digit `course_number` and an optional letter. Examples: CSMC132, BMGT468Z.

`name`: string name of course, such as 'Academic Writing' ƒor ENGL101

`dept_id`: Four-letter string like ENGL or BMGT

`department`: Full name of the department that offers a course

`semester`: Six-digit number identifying the semester the course is offered. Currently, the API only offers courses for the current semester, but that will change soon. 

`credits`: One-digit number of credits the course is worth 

`grading_method`: Array of string grading options available. The possible options are `"Regular", "Pass-Fail", "Audit", and "Sat-Fail"`

`core`: Array of the string CORE requirements filled by a course.

`gen_ed`: Array of the string General Education requirements filled by a course.

`description`: String description of a course.

`relationships`: JSON object with the relationships and restrictions of a course. The object's properties can be: `coreqs`, `prereqs`, `restrictions`, `restricted_to`, `credit_only_granted_for`, `credit_granted_for`,`formerly`, and `also_offered_as`.

`sections`: Array of `section_id` strings of the sections of a course. See [section object](#section_object).

<!-- EXAMPLE -->
**Sample course object**

`{"course_id": "ENEE380",`
`"name": "Electromagnetic Theory",`
`"dept_id": "ENEE",`
`"department": "Electrical & Computer Engineering",`
`"semester": "201501",`
`"credits": "3",`
`"grading_method": ["Regular"],`
`"core": [],`
`"gen_ed": [],`
`"description": "Prerequisite: PHYS271, PHYS270, and MATH241; and completion of all lower-division technical courses in the EE curriculum.Introduction to electromagnetic fields. Coulomb's law, Gauss's law, electrical potential, dielectric materials capacitance, boundary value problems, Biot-Savart law, Ampere's law, Lorentz force equation, magnetic materials, magnetic circuits, inductance, time varying fields and Maxwell's equations.ENEE majors (09090) only.",`
`"relationships": {`
`"coreqs": [],`
`"prereqs": ["Prerequisite: PHYS271, PHYS270, and MATH241; and completion of all lower-division technical courses in the EE curriculum"],`
`"restrictions": [],`
`"restricted_to": [],`
`"credit_only_granted_for": [],`
`"credit_granted_for": [],`
`"formerly": [],`
`"also_offered_as": []`
`},`
`"sections": ["ENEE380-0101","ENEE380-0102","ENEE380-0103"]}`

<!-- END -->