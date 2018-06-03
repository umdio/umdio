---
layout: post
title: Pagination
slug: pagination
category: api
---

Endpoints that return a large amount of items are paginated to 30 items by default. You can specify further pages with the `?page` parameter. You can also set a custom page size up to 100 with the `?per_page` parameter.

*Note that page numbering is 1-based and that omitting the ?page parameter will return the first page.*

----

### Link Header:

The possible `rel` values are:

|Name	|Description                                             |
|-------|--------------------------------------------------------|
|`next`	|Shows the URL of the immediate next page of results.    |
|`last`	|Shows the URL of the last page of results.              |
|`first`|Shows the URL of the first page of results.             |
|`prev`	|Shows the URL of the immediate previous page of results.|

<!-- EXAMPLE -->

*Example:* `https://api.umd.io/v0/courses?page=2&per_page=100`

<br><br><br><br><br><br><br>

#### Response Link Header:
```
Link: <https://api.umd.io/v0/courses?page=2&per_page=100>; rel=”next”, <https://api.umd.io/v0/courses?page=1&per_page=100>; rel=”prev”
```

<!-- END_EXAMPLE -->