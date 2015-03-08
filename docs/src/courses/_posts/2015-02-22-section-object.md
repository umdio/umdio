---
layout: post
title: Section object
slug: section_object
category: courses
---

The section object represents a single section of a course. The properties of a section are:

`section_id` -- a unique section identifier, like *ENES100-0101*. Always the related `course_id` with a four-digit section number appended to it. 

`course_id` -- The course that the section belongs to.

`instructors` -- An Array of names of the instructors for this section.

`seats` -- The total number of seats offered in a section.

`semester` -- Six-digit number specifying the semester a course is offered.

`meetings` -- Array of JSON objects with the following properties: 
  `days`: string of days for that meeting, like *"MWF", "TuTh"*.
  `start_time`: start time of the meeting, like *"9:00am"*.
  `end_time`: end time of the meeting.
  `building`: building where the meeting takes place, like *"KEY"*.
  `room`: Four digit room code where the meeting takes place.
  `classtype`: String indicates what type of meeting. Could be *"Lecture"*, *"Discussion"*, or *"Lab"*.

<!-- EXAMPLE -->
**Sample section object**

{% highlight json %}
{
  "section_id": "ENGL101-0101",
  "course_id": "ENGL101",
  "instructors": [
    "Christopher Philpot"
  ],
  "seats": "19",
  "semester": "201501",
  "meetings": [
    {
      "days": "MWF",
      "start_time": "9:00am",
      "end_time": "9:50am",
      "building": "KEY",
      "room": "0120",
      "classtype": "Lecture"
    }
  ]
}
{% endhighlight %}

<!-- END -->
