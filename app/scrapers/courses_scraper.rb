# Script for adding umd testudo courses to a mongodb database using open-uri and nokogiri
# Use: ruby courses_scraper.rb <years>

require 'open-uri'
require 'nokogiri'
require 'mongo'
require 'pg'

require_relative 'scraper_common.rb'
include ScraperCommon
db = PG.connect(
      dbname: 'umdio',
      host: 'postgres',
      port: '5432',
      user: 'postgres'
    )
prog_name = "courses_scraper"

logger = ScraperCommon::logger

db = ScraperCommon::postgres

# List semesters in year in testudo's format
# 2018 -> 201801, 201805, 201808, 201812
semesters = ScraperCommon::get_semesters(ARGV)

logger.info(prog_name) {semesters}

# Get the urls for all the department pages
dep_urls = []
semesters.each do |semester|
  logger.info(prog_name) {"Searching for courses in term #{semester}"}

  base_url = "https://ntst.umd.edu/soc/#{semester}"

  Nokogiri::HTML(open(base_url)).search('span.prefix-abbrev').each do |e|
    dep_urls << "https://ntst.umd.edu/soc/#{semester}/#{e.text}"
  end

  logger.info(prog_name) {"#{dep_urls.length} department/semesters so far"}
end

# safely formats to UTF-8
def utf_safe text
  if !text.valid_encoding?
    text = text.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
  end
  text
end

queries = []

# add the courses from each department to the database
dep_urls.each do |url|
  dept_id = url.split('/soc/')[1][7,10]
  semester = url.split('/soc/')[1][0,6]
  courses = []
  table_name = "courses"

  logger.info(prog_name) {"Getting courses for #{dept_id} (#{semester})"}

  page = Nokogiri::HTML(open(url), nil, "UTF-8")
  department = page.search('span.course-prefix-name').text.strip

  page.search('div.course').each do |course|
    course_id = course.search('div.course-id').text
    course_title = course.search('span.course-title').text
    credits = course.search('span.course-min-credits').text

    # courses have 2 'course texts': approved-course-texts and course-texts
    # approved-course-texts has 2 child divs: relationships and description (if there are any relationships)
    # other course-texts will have relationships mixed in with description
    #
    # if course has both approved-course-text and course-texts, only first set of
    #     relationships will be parsed. anything in course-texts will be placed in "additional info"
    #
    # algorithm finds relationships and, if they exist, removes them from the description
    # searches both approved-course-texts > div:first-child and course-texts > div for relationships
    # leftover text will either be description (if approved-course-texts is empty) or additional info

    approved = course.search('div.approved-course-texts-container')
    other = course.search('div.course-texts-container')

    # get all relationship text
    if approved.css('> div').length > 1
      text = approved.css('> div:first-child').text.strip + other.css('> div').text.strip
    else
      text = other.css('> div').text.strip
    end

    text = utf_safe text

    # match all relationships, remove them from the description

    match = /Prerequisite: ([^.]+\.)/.match(text)
    text = match ? text.gsub(match[0], '') : text
    prereq = match ? match[1] : nil

    match = /Corequisite: ([^.]+\.)/.match(text)
    text = match ? text.gsub(match[0], '') : text
    coreq = match ? match[1] : nil

    match = /(?:Restricted to)|(?:Restriction:) ([^.]+\.)/.match(text)
    text = match ? text.gsub(match[0], '') : text
    restrictions = match ? match[1] : nil

    match = /Credit (?:(?:only )|(?:will be ))?granted for(?: one of the following)?:? ([^.]+\.)/.match(text)
    text = match ? text.gsub(match[0], '') : text
    credit_granted_for = match ? match[1] : nil

    match = /Also offered as:? ([^.]+\.)/.match(text)
    text = match ? text.gsub(match[0], '') : text
    also_offered_as = match ? match[1] : nil


    match = /Formerly:? ([^.]+\.)/.match(text)
    text = match ? text.gsub(match[0], '') : text
    formerly = match ? match[1] : nil

    match = /Additional information: ([^.]+\.)/.match(text)
    text = match ? text.gsub(match[0], '') : text
    additional_info = match ? match[1] : nil

    # if approved-course-texts held relationships, use 2nd child as description and leftover text as "additional info"
    if approved.css('> div').length > 0

      description = (utf_safe approved.css('> div:last-child').text).strip.gsub(/\t|(\r\n)/, '')
      additional_info = additional_info ? additional_info += ' '+text : text
      additional_info = additional_info && additional_info.strip.empty? ? nil : additional_info.strip

    elsif other.css('> div').length > 0
      description = text.strip.empty? ? nil : text.strip
    end

    relationships = {
      prereqs: prereq,
      coreqs: coreq,
      restrictions: restrictions,
      credit_granted_for: credit_granted_for,
      also_offered_as: also_offered_as,
      formerly: formerly,
      additional_info: additional_info
    }

    courses << {
      course_id: course_id,
      name: course_title,
      dept_id: dept_id,
      department: department,
      semester: semester,
      credits: course.css('span.course-min-credits').first.content,
      grading_method: course.at_css('span.grading-method abbr') ? course.at_css('span.grading-method abbr').attr('title').split(', ') : [],
      core: utf_safe(course.css('div.core-codes-group').text).gsub(/\s/, '').delete('CORE:').split(','),
      gen_ed: utf_safe(course.css('div.gen-ed-codes-group').text).gsub(/\s/, '').delete('General Education:').split(','),
      description: description,
      relationships: relationships
    }
  end

  courses.each do |course|
    res = db.exec_prepared("insert_courses", [
      course[:course_id],
      course[:semester],
      course[:name],
      course[:dept_id],
      course[:department],
      course[:credits],
      course[:description],
      PG::TextEncoder::Array.new.encode(course[:grading_method]),
      PG::TextEncoder::Array.new.encode(course[:gen_ed]),
      course[:relationships].to_json
    ])
  end
end
