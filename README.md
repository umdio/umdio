A very early attempt at an API for UMD data

Status: script scrapes schedule data from testudo and inserts into a mongodb database, sinatra server serves with a limited api. All development is still local, no live server yet.

Next: split sections to separate database objects referenced by courses 
improve api
figure out how to modularize sinatra routes
create repo, detail development/contribution process and design specs


Contributing: Getting Started
install git
install ruby
install mongodb
install ruby mongo driver
install json-ext
install sinatra
install sinatra-contrib

git clone this repo
get the mongo database up and running
run schedule/data/courses_scraper.rb
run server.rb
check development at localhost:4567

Contributing:Development Workflow
design the endpoint you want to create, i.e /courses/list
add the get '/<endpoint>' method to the sinatra server file
add some hello world code to see that the basics are working
run server.rb
add functionality

Contributing:Read more
You'll probably be referencing the docs for sinatra as well as the ruby-mongo driver a lot, especially at first, on top of the api design doc. 