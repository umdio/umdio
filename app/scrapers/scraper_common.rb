require 'open-uri'
require 'nokogiri'
require 'logger'
require 'sequel'

module ScraperCommon
  # TODO: Load config from memory
  $DB = Sequel.connect('postgres://postgres@postgres:5432/umdio')
  $DB.extension :pg_array, :pg_json

  # @return [Logger]
  def logger
    if @logger
      @logger
    else
      @logger = Logger.new(STDOUT)
      @logger.level = ENV['LOG_LEVEL'] || Logger::INFO
      @logger.formatter = proc do |severity, datetime, progname, msg|
        date_format = datetime.strftime('%Y-%m-%d %H:%M:%S')
        "[#{date_format}] #{severity}  (#{progname}): #{msg}\n"
      end
      @logger
    end
  end

  # Takes in a list of years and semesters. It maps years to 4 semesters, and semesters to themselves
  # 2018 -> 201801, 201805, 201808, 201812
  # 201901 -> 201901
  #
  # @param [Array<String>] args  a list of years
  # @return [Array<String>] list of semesters for each year
  def get_semesters(args)
    if args.is_a? Integer
      raise ArgumentError.new "#{args} is not a valid year" unless args > 1800
      args = [args.to_s]
    elsif args.is_a? String
      raise ArgumentError.new "#{args} is not a valid year" unless /\d{4}/.match? args
      args = [args]
    end

    raise ArgumentError.new "#{args} is not a valid year or list of years" unless args.respond_to? :map
    semesters = args.map do |e|
      if e.length == 6
        e
      else
        [e + '01', e + '05', e + '08', e + '12']
      end
    end
    semesters.flatten
  end

  # Creates a Nokogiri Document from a webpage. Throws if the URL or the page
  # it points to is invalid (i.e. page not found, isnt valid HTML, etc).
  #
  # @param [String] url       location of the page to get
  # @param [string] prog_name the name of the scraper to pass as a label to the logger
  #
  # @return [Nokogiri::HTML::Document]
  def get_page(url, prog_name)
    begin
      page = Nokogiri::HTML(URI.open(url))
    rescue OpenURI::HTTPError => e
      logger.error(prog_name) { "Could not load page '#{url}': #{e.message}" }
      raise
    end
    page
  end
end
