# Takes an existing semester live on umd.io and exports it to JSON
# TODO: Update to use v1 schema, but only when courses_importer does too
# TODO: Use logger

require 'open-uri'
require 'json'

def export_sem(sem)
  courses = []
  n = 0

  while (res = open("https://api.umd.io/v0/courses?semester=#{sem}&expand=sections&page=#{n}").read)
    break if res == '[]'

    j = JSON.parse(res)

    j.each do |course|
      courses << course
    end
    n += 1
    puts "Getting page #{n}"
  end

  File.open("./data/umdio-data/courses/#{sem}.json", 'w') do |f|
    f.write(courses.to_json)
  end
end

ARGV.each do |sem|
  export_sem sem
end
