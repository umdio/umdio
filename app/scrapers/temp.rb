# temp scraper to find open seat info

require 'open-uri'
require 'nokogiri'

sec_ids = ["ENES100-0101","ENES100-0201","ENES100-0301","ENES102-0102"]
course_ids = sec_ids.map{|id| id.scan(/(.+)-/)}.uniq.flatten
query = "https://ntst.umd.edu/soc/201508/sections?courseIds=#{course_ids.join(',')}"
puts query
page = Nokogiri::HTML(open(query))

course_ids.each do |course|
  puts course
  course_div = page.css("\#"+course.to_s)
  course_div.search("div.section").each do |sec_div|
    sec_id = "#{course}-#{sec_div.search('span.section-id').text.strip}"
    open = sec_div.search("span.open-seats-count").text
    wait = sec_div.search("span.waitlist-count").text
    #insert to mongodb
    puts "#{sec_id} has #{open} open and #{wait} on waitlist"
  end
end