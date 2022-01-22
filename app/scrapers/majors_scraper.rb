require 'open-uri'
require 'nokogiri'
require 'ruby-progressbar'

require_relative 'scraper_common'

require_relative '../models/majors'

class MajorsScraper
  include ScraperCommon
  attr_accessor :prog_name, :majors_regex

  @@page_url = 'https://admissions.umd.edu/explore/colleges-and-schools/majors/majors-alphabetically'

  def self.url
    @@page_url
  end

  def initialize
    @majors_regex = /(.+)\|(.+)/  # Extracts info from a single major page entry
    @prog_name = 'majors_scraper' # provide a progname label for logger
    logger.progname = @prog_name
  end

  # Scrapes the admissions page for a list of majors
  #
  # @param [Nokogiri::HTML::Document] page the HTML page to extract majors from
  # @return [Array<Major>] a list of majors found on the page
  def scrape_page(page)
    major_divs = page.css('.page--inner-content a')
    majors = []
    bar = get_progress_bar(title: "#{self.class} - Scraping Majors", total: major_divs.length)
    major_divs.each do |link|
      # parse the name to grab the major's name and its college

      major_url = link['href']
      next unless major_url&.include?('umd.edu')

      major_parts = majors_regex.match(link.text)

      next if major_parts.nil?

      # 0th match is full string, 1st and 2nd elements are the two matches
      # use [[:space:]] here to get rid of leading and trailing nonbreaking spaces, which are present in the major
      # name and college. A regular .strip is insufficient.
      major_name, major_college = major_parts[1, 3].map { |str| str.gsub(/^[[:space:]]*(.*?)[[:space:]]*$/, '\1') }

      bar.increment
      majors << {
        name: major_name,
        college: major_college,
        url: major_url
      }
    end

    bar.finish
    majors
  end

  # @param [Array<Major>]
  # @return [void]
  def update_db(majors)
    bar = get_progress_bar(title: "#{self.class} - Loading Majors", total: majors.length)
    $DB[:majors].delete
    majors.each do |major|
      log(bar, :info) { "inserting #{major[:name]}" }
      p major

      major[:major_id] = major[:name].upcase.gsub!(/[^0-9A-Za-z]/, '')
      major[:major_id] = major[:name].upcase if major[:major_id].nil?
      $DB[:majors].insert_ignore.insert(major_id: major[:major_id], name: major[:name], college: major[:college],
                                        url: major[:url])
      bar.increment
    end
    nil
  end

  # Runs the scraper and updates the Majors table
  # @return [void]
  def scrape
    url = 'https://admissions.umd.edu/explore/colleges-and-schools/majors/majors-alphabetically'
    page = get_page url, prog_name
    majors = scrape_page page
    update_db(majors)
  end
end

MajorsScraper.new.run_scraper if $PROGRAM_NAME == __FILE__
