# Imports course data from a JSON file
# TODO: Update to use V1 schema

require 'json'
require_relative 'scraper_common.rb'
include ScraperCommon

require_relative '../models/courses.rb'

$course_map = {
  AOSC201: 'AOSC201',
  BSCI125: 'BSCI125',
  BSCI161: 'BSCI161',
  BSCI171: 'BSCI171',
  BSST241: 'BSST241',
  O211: 'GEOG211',
  OL110: 'GEOL110',
  CHM132: 'CHEM132',
  PHYS103: 'PHYS103',
  PHYS107: 'PHYS107',
  PHYS261: 'PHYS261',
  PHYS271: 'PHYS271',
  PHYS275: 'PHYS275'
}

def gened_v0_to_text(arr)
  str = ''
  arr.each do |s|
    if m = s.match(/^(.{4})$/)
      str += m[0] + ', '
    elsif m = s.match(/^(.{4})(.{4})$/)
      str += m[1] + ' or ' + m[2] + ', '
    elsif m = s.match(/^(.{4})(.{4})(.{4})$/)
      str += m[1] + ' or ' + m[2] + ' or ' + m[3] + ', '
    elsif m = s.match(/^(.{4})\(fkwh(.*)\)$/)
      puts m[2] unless $course_map.key? m[2].to_sym

      str += m[1] + "(if taken with #{$course_map[m[2].to_sym]}), "
    elsif m = s.match(/^(.{4})\(fkwh(.*)\)(.{4})$/)
      puts m[2] unless $course_map.key? m[2].to_sym

      str += m[1] + "(if taken with #{$course_map[m[2].to_sym]}) or " + m[3]
    else
      puts ':('
      puts s
    end
  end
  str = str.chomp(', ') unless str == ''

  str
end

prog_name = 'courses_importer'
logger = ScraperCommon.logger

file = File.read("./data/umdio-data/courses/data/#{ARGV[0]}.json")

j = JSON.parse(file)

j.to_a.each do |course|
  $DB[:courses].insert_ignore.insert(
    course_id: course['course_id'],
    semester: course['semester'],
    name: course['name'],
    dept_id: course['dept_id'],
    department: course['department'],
    credits: course['credits'],
    description: course['description'],
    grading_method: Sequel.pg_jsonb_wrap(course['grading_method']),
    gen_ed: (gened_v0_to_text course['gen_ed']),
    core: Sequel.pg_jsonb_wrap(course['core']),
    relationships: Sequel.pg_jsonb_wrap(course['relationships'])
  )

  course['sections'].each do |section|
    $DB[:sections].insert_ignore.insert(
      section_id_str: section['section_id'],
      course_id: course['course_id'],
      semester: section['semester'],
      number: section['number'],
      seats: section['seats'],
      open_seats: section['open_seats'],
      waitlist: section['waitlist']
    )

    s = $DB[:sections].where(section_id_str: section['section_id'], course_id: course['course_id'], semester: section['semester']).first

    section['meetings'].each do |meeting|
      $DB[:meetings].insert_ignore.insert(
        section_key: s['section_id'],
        days: meeting['days'],
        room: meeting['room'],
        building: meeting['building'],
        classtype: meeting['classtype'],
        start_time: meeting['start_time'],
        end_time: meeting['end_time'],
        start_seconds: meeting['start_seconds'],
        end_seconds: meeting['end_seconds']
      )
    end

    section['instructors'].each do |prof|
      $DB[:professors].insert_ignore.insert(
        name: prof
      )

      pr = $DB[:professors].where(name: prof).first

      # puts s
      # puts pr

      $DB[:professors_sections].insert_ignore.insert(
        section_id: s[:section_id],
        professor_id: pr[:professor_id]
      )
    end
  end
end
