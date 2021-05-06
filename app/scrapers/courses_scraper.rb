# Script for adding umd testudo courses to a mongodb database using open-uri and nokogiri
# Use: ruby courses_scraper.rb <years>

require 'open-uri'
require 'nokogiri'

require_relative 'scraper_common'
require_relative '../models/courses'

class CoursesScraper
  include ScraperCommon

  ##
  # List of semesters being parsed
  #
  # @return [Array<String>]
  def semesters
    @semesters ||= get_semesters(ARGV)
  end

  ##
  # Get the urls for all the department pages
  #
  # @return [Array<String>]
  def get_department_urls
    # @type [Array<String>]
    dept_urls = []
    bar = get_progress_bar title: "#{self.class} - Scraping Dept URLs", total: semesters.length
    semesters.each do |semester|
      log(bar, :debug) { "Searching for courses in term #{semester}" }

      base_url = "https://app.testudo.umd.edu/soc/#{semester}"

      get_page(base_url).search('span.prefix-abbrev').each do |e|
        dept_urls << "https://app.testudo.umd.edu/soc/#{semester}/#{e.text}"
      end

      log(bar, :debug) { "#{dept_urls.length} department/semesters so far" }
      bar.increment
    end

    dept_urls
  end

  ##
  # Scrapes relationship data from an HTML element containing course data
  #
  # courses have 2 'course texts': `approved-course-texts` and `course-texts`.
  # `approved-course-texts` has 2 child divs: `relationships` and `description`
  # (if there are any relationships). `other` `course-texts` will have
  # relationships mixed in with description.
  #
  # if `course` has both `approved-course-text` and `course-texts,` only the
  # first set of relationships will be parsed. anything in `course-texts` will
  # be placed in `:additional_info`.
  #
  # algorithm finds relationships and, if they exist, removes them from the
  # description. It searches both `approved-course-texts > div:first-child` and
  # `course-texts > div` for relationships. After searching, the leftover text
  # will either be `description` (if `approved-course-texts` is empty) or
  # `:additional_info`.
  #
  # @param course the course element to scrape
  # @return [Array(String, {Symbol => String, nil})] An Array containing the courses `description` and `relationship` info hash.
  #
  def scrape_relationships(course)
    approved = course.search('div.approved-course-texts-container')
    other = course.search('div.course-texts-container')

    # get all relationship text
    text = if approved.css('> div').length > 1
             approved.css('> div:first-child').text.strip + other.css('> div').text.strip
           else
             other.css('> div').text.strip
           end

    text = utf_safe text

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
      additional_info = additional_info ? additional_info += ' ' + text : text
      additional_info = additional_info&.strip&.empty? ? nil : additional_info.strip

    elsif other.css('> div').length > 0
      description = text.strip.empty? ? nil : text.strip.gsub(/\t|\r|\n/, '')
    end

    [description || '', {
      prereqs: prereq,
      coreqs: coreq,
      restrictions: restrictions,
      credit_granted_for: credit_granted_for,
      also_offered_as: also_offered_as,
      formerly: formerly,
      additional_info: additional_info
    }]
  end

  ##
  # Scrapes courses from department pages. Each course found is yielded as a
  # hash.
  #
  # @param [String] url the URL of the department page being scraped
  # @param [ProgressBar, Nil] bar the progress bar currently in use, if applicable
  #
  # @yieldparam [Hash] course a course hash scraped from the department page
  #
  def scrape_department_page(url, bar = nil)
    raise ArgumentError, 'no block' unless block_given?

    dept_id = url.split('/soc/')[1][7, 10]
    semester = url.split('/soc/')[1][0, 6]

    log(bar, :debug) { "Getting courses for #{dept_id} (#{semester})" }

    # TODO: replace this with ScraperCommon::get_page if we don't need the 'UTF-8'
    # options thingy
    begin
      page = Nokogiri::HTML(URI.open(url), nil, 'UTF-8')
    rescue OpenURI::HTTPError => e
      log(bar, :error) { "Failed to get department page at '#{url}': #{e.message}" }

      raise $!
    end

    department = page.search('span.course-prefix-name').text.strip

    page.search('div.course').each do |course|
      course_id = course.search('div.course-id').text

      # Rejects course ids that are longer than expected
      next if course_id.length > 8

      course_title = course.search('span.course-title').text
      credits = course.search('span.course-min-credits').text
      description, relationships = scrape_relationships course

      log(bar, :debug) { "Scraped #{course_id}: #{course_title} (#{semester})"}
      yield ({
        course_id: course_id,
        name: course_title,
        dept_id: dept_id,
        department: department,
        semester: semester,
        credits: course.css('span.course-min-credits').first.content,
        grading_method: course.at_css('span.grading-method abbr') ? course.at_css('span.grading-method abbr').attr('title').split(', ') : [],
        core: utf_safe(course.css('div.core-codes-group').text).gsub(/\s/, '').delete('CORE:').split(','),
        gen_ed: utf_safe(course.css('div.gen-ed-codes-group').text).delete('General Education:'),
        description: description,
        relationships: relationships
      })
    end
  end

  def scrape
    queries = []
    dept_urls = get_department_urls
    dept_count = dept_urls.length
    bar = get_progress_bar title: "#{self.class} - Scraping Courses", total: dept_count

    # add the courses from each department to the database
    dept_urls.each do |url|
      scrape_department_page(url, bar) do |course|
        $DB[:courses].insert_ignore.insert(
          course_id: course[:course_id],
          semester: course[:semester],
          name: course[:name],
          dept_id: course[:dept_id],
          department: course[:department],
          credits: course[:credits],
          description: course[:description],
          grading_method: Sequel.pg_jsonb_wrap(course[:grading_method]),
          gen_ed: course[:gen_ed],
          core: Sequel.pg_jsonb_wrap(course[:core]),
          relationships: Sequel.pg_jsonb_wrap(course[:relationships])
        )
      end

      bar.increment
    end
  end
end

CoursesScraper.new.run_scraper if $PROGRAM_NAME == __FILE__
