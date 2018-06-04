---
layout: post
title: Expanding objects
slug: expanding_objects
category: api
---

Queries that return the ID of another object nested within the result can be expanded via the `?expand=<object>` parameter. For example, the query `https://api.umd.io/v0/courses/cmsc131` returns a "sections" key with an array of Section object ids. To expand these into their full objects, you can pass `?expand=sections` to expand the section ids to their section objects.

<!-- EXAMPLE -->

Example expand query: `https://api.umd.io/v0/courses/cmsc131?expand=sections`

Currently, this only works on the [Get courses](/courses/#get_courses) endpoint.

<!-- END_EXAMPLE -->