---
layout: post
title: Get sections
slug: get_sections
category: courses
---

Get information about a section or multiple sections.

----

`https://api.umd.io/v0/courses/sections/<section_id>`

To get information about a single section, append the `section_id` to the sections root URL.

*Returns*: The specified [section object](#section_object) or `null`

----

`https://api.umd.io/v0/courses/sections/<section_ids>`

To get information about multiple sections, append comma-separated `section_id`s to the sections root URL.

*Returns*: Array of specified [section objects](#section_object). If one of the sections does not exist, the rest are still returned.

<!-- EXAMPLE -->



<!-- END -->