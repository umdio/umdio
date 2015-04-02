#script for adding umd testudo courses to a mongodb database using mechanize and nokogiri

#we need mongo, nokogiri for parsing, and mechanize to make things smoother
ENV['RACK_ENV'] ||= 'scrape'

require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

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

#set the collections (courses and sections), clear the collection if anything was there before
coll = db.collection('courses')
sect_coll = db.collection('sections')
coll.remove
sect_coll.remove

semester = '201501' #the current semester's prefix

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
  dept_id = dep_home.search('span.course-prefix-abbr').text.strip
  puts "searching the #{department} department"

  #iterate through the courses in the department
  dep_home.search('div.course').each do |course|

    #get course info, assign to variables
    #should probably be doing null checks each time to be safe (or maybe rescuing?)
    name = course.css('span.course-title').first.content
    course_id = course.search('div.course-id').text
    credits = course.css('span.course-min-credits').first.content
    gm_span = course.css('span.grading-method abbr')
    if (gm_span.first) then grading_method = gm_span.first.attr('title').split(', ') end
    core = course.css('div.core-codes-group').text.gsub(/\s/, '').delete('CORE:').split(',')
    gen_ed = course.css('div.gen-ed-codes-group').text.gsub(/\s/, '').delete('General Education:').split(',')

    description = course.css('div.approved-course-texts-container').text + course.css('div.course-texts-container').text
    description = description.strip.gsub(/\t|\r\n/,'')

    #Match pattern against description
    course_relationships = {
      :coreqs => /Corequisite: [^.]+/.match(description).to_a,
      :prereqs => /Prerequisite: [^.]+/.match(description).to_a,
      :restrictions => /(Restriction: [^.]+)/.match(description).to_a,
      :restricted_to => /Restricted to [^.]+/.match(description).to_a,
      :credit_only_granted_for => /Credit only granted for:[^.]+/.match(description).to_a,
      :credit_granted_for => /Credit granted for[^.]+/.match(description).to_a,
      :formerly => /Formerly:[^.]+/.match(description).to_a,
      :also_offered_as => /Also offered as[^.]+/.match(description).to_a
    }

    # TODO: we need to think more about how we figure out what other semesters a class is offered, and how we find out
    #semesters_offered = [semester]


    ###############################################################
    #                                                             #
    #            Getting the Section data for the course          #
    #                                                             #
    ###############################################################

    section_page = agent.get(section_base + '?courseIds=' + course_id)

    #set up array to hold different sections of a class
    sections = []

    #walk through each section, adding sections to collection of sections
    section_page.search('div.section').each do |section|
      number = section.search('span.section-id').text.gsub(/\s/, '')
      instructors = section.search('span.section-instructors').text.strip.split(',')
      seats = section.search('span.total-seats-count').text
      section_id = "#{course_id}-#{number}"

      #array for different times a class meets
      meetings = []

      #walk through different class meetings and add data to meetings array
      section.search('div.class-days-container div.row').each do |meeting|
        days = meeting.search('span.section-days').text
        start_time = meeting.search('span.class-start-time').text
        end_time = meeting.search('span.class-end-time').text
        building = meeting.search('span.building-code').text
        room = meeting.search('span.class-room').text
        classtype = meeting.search('span.class-type').text

        classtype = "Lecture" if classtype.empty?

        # actually add the meeting to the array
        meetings << {
          :days => days,
          :start_time => start_time,
          :end_time => end_time,
          :building => building,
          :room => room,
          :classtype => classtype
        }
      end

      #add the section info into the sections collection on the database
      _id = sect_coll.insert({
        :section_id => section_id,
        :course => course_id,
        :number => number,
        :instructors => instructors,
        :seats  => seats,
        :semester => semester,
        :meetings => meetings
      })

      #add the section to the sections array for the course
      sections << {
        :section_id => section_id,
        :_id => _id       #we may use this to , but we shouldn't return it to users!
      }

    end

    ####################################################################
    #                                                                  #
    #             Inserting the Course into the Database               #
    #                                                                  #
    ####################################################################


    puts "adding #{course_id}"
    #add the course to the database!
    coll.insert({
      :course_id => course_id,
      :name => name,
      :dept_id => dept_id,
      :department => department,
      :semester => semester,
      :credits => credits,
      :grading_method => grading_method,
      :core => core,
      :gen_ed => gen_ed,
      :description => description,
      :relationships => course_relationships,
      :sections => sections
    })
    
  end

end
