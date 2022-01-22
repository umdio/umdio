require 'open-uri'
require 'nokogiri'

require_relative '../helpers/courses_helpers'
include Sinatra::UMDIO::Helpers

require_relative 'scraper_common'

require_relative '../models/courses'

# Inital setup
# prog_name = 'sections_scraper'
# logger = ScraperCommon.logger

class SectionsScraper
  include ScraperCommon

  ##
  # Parses a given section page.
  #
  # TODO: Remove semester param, infer from url
  #
  # @param [String] url       URL of the section page
  # @param [String] semester  The semester the sections occur during.
  #
  # @yieldparam section [Hash] a hash of section data extracted from the page
  #
  def parse_sections(url, semester)
    # Parse with Nokogiri
    page = get_page url

    course_divs = page.search('div.course-sections')

    # for each of the courses on the page
    course_divs.each do |course_div|
      course_id = course_div.attr('id')
      # for each section of the course
      course_div.search('div.section').each do |section|
        # NOTE: some courses have weird suffixes (e.g. MSBB99MB, yes thats a real class)
        dept = course_id[0, 4]

        # Get list of professors teaching the course
        # @type [Array<String>]
        profs = section.search('span.section-instructors .section-instructor')
                       .map { |prof| utf_safe(prof.text).strip }
                       .filter { |prof| prof != 'Instructor: TBA' }
                       .map { |prof| prof.gsub(/\t|\r\n/, '').squeeze(' ') }
                       .uniq

        meetings = []
        section.search('div.class-days-container div.row').each do |meeting|
          start_time = meeting.search('span.class-start-time').text
          end_time = meeting.search('span.class-end-time').text

          meetings << {
            days: meeting.search('span.section-days').text,
            start_time: start_time,
            end_time: end_time,
            start_seconds: time_to_int(start_time),
            end_seconds: time_to_int(end_time),
            building: meeting.search('span.building-code').text,
            room: meeting.search('span.class-room').text,
            classtype: meeting.search('span.class-type').text || 'Lecture'
          }
        end

        number = section.search('span.section-id').text.gsub(/\s/, '')
        open_seats = section.search('span.open-seats-count').text
        waitlist = section.search('span.waitlist-count').text

        log(@bar, :debug) { "Adding #{course_id}-#{number} in #{semester} taught by #{profs.join(', ')}" }
        section_data = {
          section_id: "#{course_id}-#{number}",
          course_id: course_id,
          number: number,
          instructors: profs,
          seats: section.search('span.total-seats-count').text,
          semester: semester,
          meetings: meetings,
          open_seats: open_seats,
          waitlist: waitlist
        }
        yield section_data
      end # !each course section
    end # !each course div
  end

  ##
  # Makes a URL for getting sections for courses
  #
  # @param [String] semester the semester of the courses being queried
  # @param [Array<String | Number>] courses the courses to get (e.g. CMSC351)
  #
  # @return [String] the URL to pass to `parse_sections`
  #
  def make_query(semester, courses)
    raise ArgumentError, 'bad semester argument' if semester.nil? or !semester.respond_to? :to_s
    raise ArgumentError, 'courses must be a list' unless courses.respond_to? :join

    "https://app.testudo.umd.edu/soc/#{semester}/sections?courseIds=#{courses.map { |e| e }.join(',')}"
  end

  ##
  # Gets section data for known courses.
  #
  # @param [Array<String>] semesters the semesters to get section information for
  #
  # @yieldparam section [Hash] a hash of section data extracted from the page
  #
  def get_sections(semesters, &block)
    raise 'No block provided for get_sections' unless block_given?

    # Total number of sections being processed
    # @type [Integer]
    total_sections = $DB[:courses].where(semester: semesters).count
    @bar = get_progress_bar total: total_sections

    semesters.each do |semester|
      $DB[:courses].select(:course_id).where(semester: semester).each_page(200) do |page|
        # @type [Array<String>]
        courses = page.map { |row| row[:course_id] } # list of course IDs
        query = make_query(semester, courses) # URL to get page of sections
        parse_sections(query, semester, &block) # extract sections from page
        @bar.progress += courses.length
      end
    end
  end

  def scrape
    semesters = get_semesters(ARGV)

    # Now, insert all our stuff to the db
    get_sections(semesters) do |section|
      log(@bar, :debug) { "Inserting section #{section[:section_id]} for #{section[:course_id]} (#{section[:semester]})" }

      on_update = {
        section_id_str: Sequel[:excluded][:section_id_str],
        course_id: Sequel[:excluded][:course_id],
        semester: Sequel[:excluded][:semester],
        number: Sequel[:excluded][:number],
        seats: Sequel[:excluded][:seats],
        open_seats: Sequel[:excluded][:open_seats],
        waitlist: Sequel[:excluded][:waitlist]
      }

      # this constraint name is autogenerated by sequel and might actually be undefined behavior.
      # TODO use https://github.com/jeremyevans/sequel/blob/master/doc/schema_modification.rdoc#label-add_unique_constraint
      # or something like it when defining the model to guarantee the constraint name
      $DB[:sections].insert_conflict(:constraint=>:sections_section_id_str_course_id_semester_key, :update=>on_update).insert(
        section_id_str: section[:section_id],
        course_id: section[:course_id],
        semester: section[:semester],
        number: section[:number],
        seats: section[:seats],
        open_seats: section[:open_seats],
        waitlist: section[:waitlist]
      )

      s = $DB[:sections].where(section_id_str: section[:section_id], course_id: section[:course_id],
                               semester: section[:semester]).first

      # reset our meetings list every time, whatever is on testudo right now is ground truth
      $DB[:meetings].where(section_key: s[:section_id]).delete

      section[:meetings].each do |meeting|
        log(@bar, :debug) { "Inserting meeting: #{meeting}" }
        $DB[:meetings].insert(
          section_key: s[:section_id],
          days: meeting[:days],
          room: meeting[:room],
          building: meeting[:building],
          classtype: meeting[:classtype],
          start_time: meeting[:start_time],
          end_time: meeting[:end_time],
          start_seconds: meeting[:start_seconds],
          end_seconds: meeting[:end_seconds]
        )
      end

      section[:instructors].each do |prof|
        log(@bar, :debug) { "Inserting instructor #{prof}" }
        $DB[:professors].insert_ignore.insert(
          name: prof
        )

        pr = $DB[:professors].where(name: prof).first

        $DB[:professors_sections].insert_ignore.insert(
          section_id: s[:section_id],
          professor_id: pr[:professor_id]
        )
      end
    end
  end
end

SectionsScraper.new.run_scraper if $PROGRAM_NAME == __FILE__
