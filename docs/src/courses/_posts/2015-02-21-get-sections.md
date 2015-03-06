---
layout: post
title: Get sections
slug: get_sections
category: courses
---
Get information about a section or multiple sections.

To get information about a single section, append the `section_id` to the sections root URL.

Example: GET `http://api.umd.io/v0/courses/sections/ENES100-0101`

Returns: The specified [section object](#section_object) or `null`

To get information about multiple sections, append comma-separated `section_id`s to the sections root URL.

Example: GET `http://api.umd.io/v0/courses/sections/ENES100-0101,CHEM135-3125,CMSC131-0101`

Returns: Array of specified section objects. If one of the sections does not exist, the rest are still returned.

<!-- EXAMPLE -->



<!-- END -->