#script for adding umd testudo courses to a mongodb database - this time, using mechanize on top of nokogiri
#rob cobb

#TODO
#Add: Department Abbreviation
#Add: Pre/Co-requisites
#Add: Restrictions
#Add: Formerly/Also offered as
#Modify: Split sections into separate documents on the database, referenced by the courses


#we need mongo, nokogiri for parsing, and mechanize to make things smoother
  require 'mechanize'
  require 'nokogiri'
  require 'mongo'
  include Mongo

#set up mongo database - code from ruby mongo driver tutorial
  host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
  port = ENV['MONGO_RUBY_DRIVER_PORT'] || MongoClient::DEFAULT_PORT

  #announce connection and connect
  puts "Connecting to #{host}:#{port}"
  db = MongoClient.new(host, port).db('umdclass')

  #set the collection, clear the collection if anything was there before
  coll = db.collection('courses')
  coll.remove

semester = '201501'

agent = Mechanize.new
base_url = 'https://ntst.umd.edu/soc/'
section_base = "https://ntst.umd.edu/soc/#{semester}/sections"

schedule_home = agent.get(base_url)
#grab department urls from testudo schedule of classes home page
dep_urls = schedule_home.search('div.course-prefix a').map{|html| html["href"]}

puts "found #{dep_urls.length} departments"


#iterate through department pages
dep_urls.each do |dep_url|
  dep_home = agent.get(base_url + dep_url)
  department = dep_home.search('span.course-prefix-name').text.strip
  puts "searching the #{department} department"
 
  #iterate through the courses in the department
  dep_home.search('div.course').each do |course|
    
    #get course info, assign to variables 
    name = course.css('span.course-title').first.content
    credits = course.css('span.course-min-credits').first.content 
    gm_span = course.css('span.grading-method abbr')
    if (gm_span.first) then grading_method = gm_span.first.attr('title').split(', ') end
    core = course.css('div.core-codes-group').text.gsub(/\s/, '').delete('CORE:').split(',')
    gen_ed = course.css('div.gen-ed-codes-group').text.gsub(/\s/, '').delete('General Education:').split(',')
    description = course.css('div.approved-course-text').text
    semesters_offered = [semester]

    courseid = course.search('div.course-id').text
    section_page = agent.get(section_base + '?courseIds=' + courseid)
    
    #set up array to hold different sections of a class
    sections = []
    
    #walk through each section, adding data to sections array
    section_page.search('div.section').each do |section|
      number = section.search('span.section-id').text.gsub(/\s/, '')
      instructors = section.search('span.section-instructors').text.strip.split(',')
      seats = section.search('span.total-seats-count').text
      
      #array for different times a class meets
      meetings = []
      #walk through different class meetings and add data to meetings array
      section.search('div.class-days-container div.row').each do |meeting|
        days = meeting.search('span.section-days').text
        start_time = meeting.search('span.class-start-time').text
        end_time = meeting.search('span.class-end-time').text
        building = meeting.search('span.building-code').text
        room = meeting.search('span.class-room').text
        
        #actually add the meeting to the array
        meetings << {
          :days => days,
          :start_time => start_time,
          :end_time => end_time,
          :building => building,
          :room => room  
        }
      end

      #add the section to the sections array
      sections << {
        :number => number,
        :instructors => instructors,
        :seats => seats,
        :meetings => meetings
      }

    end
    puts "adding #{courseid}"
    #add the course to the courses array
    coll.insert({
      :department => department,
      :name => name,
      :code => courseid,
      :credits => credits,
      :grading_method => grading_method,
      :core => core,
      :gen_ed => gen_ed,
      :description => description,
      :sections => sections
    })
  end
  
end
