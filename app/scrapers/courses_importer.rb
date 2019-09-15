# Imports course data from a JSON file

require 'json'
require_relative 'scraper_common.rb'
include ScraperCommon

require_relative '../models/courses.rb'

prog_name = "courses_importer"
logger = ScraperCommon::logger

file = File.read("imports/#{ARGV[0]}.json")

j = JSON.parse(file)

j.to_a.each do |course|
    $DB[:courses].insert_ignore.insert(
      :course_id => course['course_id'],
      :semester => course['semester'],
      :name => course['name'],
      :dept_id => course['dept_id'],
      :department => course['department'],
      :credits => course['credits'],
      :description => course['description'],
      :grading_method => Sequel.pg_jsonb_wrap(course['grading_method']),
      :gen_ed => Sequel.pg_jsonb_wrap(course['gen_ed']),
      :core => Sequel.pg_jsonb_wrap(course['core']),
      :relationships => Sequel.pg_jsonb_wrap(course['relationships'])
    )

    course['sections'].each do |section|
        section_key = $DB[:sections].insert_ignore.insert(
            :section_id => section['section_id'],
            :course_id => section['course_id'],
            :semester => section['semester'],
            :number => section['number'],
            :seats => section['seats'],
            :open_seats => section['open_seats'],
            :waitlist => section['waitlist'],
            :instructors => Sequel.pg_jsonb_wrap(section['instructors'])
        )

        section['meetings'].each do |meeting|
            $DB[:meetings].insert_ignore.insert(
                :section_key => section_key,
                :days => meeting['days'],
                :room => meeting['room'],
                :building => meeting['building'],
                :classtype => meeting['classtype'],
                :start_time => meeting['start_time'],
                :end_time => meeting['end_time'],
                :start_seconds => meeting['start_seconds'],
                :end_seconds => meeting['end_seconds']
            )
        end

        section['instructors'].each do |prof|
            profs = Professor.where(name: prof).map{|p| p.to_v0}

            if profs.length > 1
              raise "Prof uniqueness violated"
            end

            if profs.length == 0
              $DB[:professors].insert(
                :name => prof,
                :semester => Sequel.pg_jsonb_wrap([section['semester']]),
                :courses => Sequel.pg_jsonb_wrap([section['course']]),
                :department => Sequel.pg_jsonb_wrap([section['course'][0,4]])
              )
            else
              sems = Sequel.pg_jsonb_wrap(profs[0]['semester'].to_a.push(section['semester']).uniq)
              courses = Sequel.pg_jsonb_wrap(profs[0]['courses'].to_a.push(section['course']).uniq)
              depts = Sequel.pg_jsonb_wrap(profs[0]['depts'].to_a.push(section['course'][0,4]).uniq)

              $DB[:professors].insert_conflict(target: :name, update: {semester: sems, courses: courses, department: depts}).insert(
                :name => prof,
                :semester => Sequel.pg_jsonb_wrap([section['semester']]),
                :courses => Sequel.pg_jsonb_wrap([section['course_id']]),
                :department => Sequel.pg_jsonb_wrap([section['course'][0,4]])
              )
            end
          end
    end
end