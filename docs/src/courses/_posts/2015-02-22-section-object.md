---
layout: post
title: Section object
slug: section_object
category: courses
---

The section object represents a single section of a course. The properties of a section are:

`section_id`: Sections are identified by a `section_id`, like ENES100-0101. `section_id` is always the associated `course_id` with a four-digit section number code appended to it. 

`course`: The `course_id` of the course that the section belongs to.

`number`: The four digit section number of the course.

`instructors`: An Array of names of the instructors of a course.

`seats`: The total number of seats offered in a section.

`semester`: Six-digit number specifying the semester a course is offered.

`meetings`: Array of JSON objects with the following properties: 
  `days`: string of days for that meeting, like "MWF"
  `start_time`: start time of the meeting, like "9:00am"
  `end_time`: end time of the meeting, like "9:50am"
  `building`: building where the meeting takes place, like "KEY"
  `room`: Four digit room code where the meeting takes place, like "0120"
  `classtype`: String indicates what type of meeting. Could be "Lecture", "Discussion", "Lab"

<!-- EXAMPLE -->
**Sample section object**

`{"section_id": "ENGL101-0101",`
`"course": "ENGL101",`
`"number": "0101",`
`"instructors": [`
`"Christopher Philpot"`
`],`
`"seats": "19",`
`"semester": "201501",`
`"meetings": [`
`{"days": "MWF",`
`"start_time": "9:00am",`
`"end_time": "9:50am",`
`"building": "KEY",`
`"room": "0120",`
`"classtype": "Lecture"}`
`] }`

<!-- END -->