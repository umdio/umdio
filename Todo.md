#Todo
Fix nginx.conf and nginx_site_config
figure out bus schedule test failure

##Docs:
  - License + Terms of Use
  - Tutorials for getting started with the API
  - Styling:
    - nav disappears?
    - nav link highlighting at bottom of page
  - how parameters work, generally
  - 'next page' link

##Implement:
  - queries - subfields on objects
  - limits and filters 
  - 'near' search on locations (section meetings, buildings, buses?)
  - paginate responses with headers (trim to 30 results, max 100)
  - i18n to move all string messages to a en.yml file + refer to them as variables in controllers 
  - namespace the routes
  - expand:
    - sections - works
    - courses
  - events:
    https://see.umd.edu/event/feed/
  https://see.umd.edu/feed/
  [academic calendar](http://registrar.umd.edu/calendar.html) - maybe?
  http://www.freestuff.umd.edu/events.cfm
  http://theclarice.umd.edu/calendar
  http://www.umterps.com/calendar/events/
  http://www.careercenter.umd.edu/events.cfm
  http://www.umdrightnow.umd.edu/spark
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
 - eat more databases
 - expand team
 - think about long term

##Notes:
- Security: 
  - Right now, all the data is public. Before we have any secure data, we should do an audit.
  - Eventually, a single API for UMD data is more secure than a hundred separate databases - do it right once, and then it's only one thing to keep track of.