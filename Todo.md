#Todo
nginx logs - [management](https://www.digitalocean.com/community/tutorials/how-to-configure-logging-and-log-rotation-in-nginx-on-an-ubuntu-vps) and analysis with [GoAccess](http://goaccess.io/) or [visitors](http://www.hping.org/visitors/) or maybe the [request-log-analyzer](https://github.com/wvanbergen/request-log-analyzer) gem.
Move cron setup into a shell script / use whenever gem
Database consistency - add track + delete to scrapers

##Docs:
  - Tutorials for getting started with the API
  - nav disappears, link highlighting at bottom of page, too many items
  - 'next page' link
  - versioning

##Implement:
  - queries on subfields - look at subfield application
  - limits and filters
  - search on buses or buildings? - buses at each stop?
  - 'near' search on locations (section meetings, buildings, buses?)
  - [i18n](http://edgeguides.rubyonrails.org/i18n.html) to move all string messages to a en.yml file + refer to them as variables in controllers 
  - namespace the routes
  - expand:
    - sections - works
    - courses
  - expire data: cron scrapers will not remove out of date objects
  - events:
    https://see.umd.edu/event/feed/
  https://see.umd.edu/feed/
  [academic calendar](http://registrar.umd.edu/calendar.html)
  [fyi](https://www.umd.edu/fyi/)
  [free events](http://www.freestuff.umd.edu/events.cfm)
  [cspac](http://theclarice.umd.edu/calendar)
  [terps calendar](http://www.umterps.com/calendar/events/)
  [career center events](http://www.careercenter.umd.edu/events.cfm)
  [umd right now](http://www.umdrightnow.umd.edu/spark)
  Twitter?

##Testing:
  - Remove hardcoding from tests
  - maps
  - buses
  - Unit tests for methods - particularly helpers
  - break tests out into features - a file per endpoint gets unwieldy
  - production tests
  - howto: test that docs are correct?

##Future:
  - Finals 
  - [Maps - more!](http://maps.umd.edu/arcgis/rest/services)
  - Budget
  - CAS
  - Refactor [this way?](http://stackoverflow.com/questions/5015471/using-sinatra-for-larger-projects-via-multiple-files)

##Meta:
 - find developers and projects
 - eat more data
 - expand team
 - think about long term

##Notes:
- Security: 
  - Right now, all the data is public. Before we have any secure data, we should do an audit.
  - Eventually, a single API for UMD data is more secure than a hundred separate databases - do it right once, and then it's only one thing to keep track of.