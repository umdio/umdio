require 'open-uri'
require 'nokogiri'
require 'logger'
require 'sequel'
require 'ruby-progressbar'

MAX_RETRIES = 2

# Base duration for delay between request retries. Measured in seconds
DELAY_BASE = 0.2
# Additional seconds to delay between each delay
DELAY_DELTA = 0.1

module ScraperCommon
  # TODO: Load config from memory
  $DB = Sequel.connect('postgres://postgres@postgres:5432/umdio')
  $DB.extension :pg_array, :pg_json, :pagination

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

  ##
  # For logging messages while a `ProgressBar` is in use. Bar is cleared and
  # reset to prevent the logged message from breaking the bar.
  #
  # @param [ProgressBar]    bar     the progress bar in progress
  # @param [String, Symbol] level   the log level to use. Defaults to `Logger::INFO`
  # @param [Hash]           opts    options hash
  #
  # @option opts [ProgressBar]    :bar        alternative to `bar` parameter. Not used if `bar` is already provided.
  # @option opts [String, Symbol] :level      alternative to `level` parameter. Not used if `level` is already provided.
  # @option opts [#to_s]          :progname   specify program name label. Defaults to the current class
  #
  # @return [void]
  #
  def log(bar = nil, level = :info, opts = {}, & block)
    raise ArgumentError, 'No block provided' unless block_given?
    raise ArgumentError, "Invalid level '#{level}'" unless logger.respond_to? level.to_s

    bar ||= opts[:bar]
    level ||= opts[:level]
    progname = opts[:progname] || self.class

    bar&.clear
    @logger.public_send(level.to_s, progname, &block)
    bar.refresh(force: true) unless bar.nil? || bar.stopped?
    nil
  end

  # Creates a new `ProgressBar` with overridable default options.
  #
  # @see https://github.com/jfelchner/ruby-progressbar/wiki/Options
  #
  # @param [Hash] [opts progress bar options](https://github.com/jfelchner/ruby-progressbar/wiki/Options) overrides
  # @return [ProgressBar]
  def get_progress_bar(opts = {})
    default_opts = { title: self.class, throttle_rate: 0.01, smoothing: 0.4, format: '%t: |%B| (%j%% - %e)' }
    ProgressBar.create(default_opts.merge(opts))
  end

  # Takes in a list of years and semesters. It maps years to 4 semesters, and semesters to themselves
  # 2018 -> 201801, 201805, 201808, 201812
  # 201901 -> 201901
  #
  # @param [Array<String>] args  a list of years
  # @return [Array<String>] list of semesters for each year
  def get_semesters(args)
    if args.is_a? Integer
      raise ArgumentError, "#{args} is not a valid year" unless args > 1800

      args = [args.to_s]
    elsif args.is_a? String
      raise ArgumentError, "#{args} is not a valid year" unless /\d{4}/.match? args

      args = [args]
    end

    raise ArgumentError, "#{args} is not a valid year or list of years" unless args.respond_to? :map

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
  # @param [String] prog_name the name of the scraper to pass as a label to the logger
  #
  # @return [Nokogiri::HTML::Document]
  def get_page(url, prog_name = self.class)
    begin
      retries ||= 0
      page = Nokogiri::HTML(URI.open(url))
    rescue OpenURI::HTTPError => e

      # Attempt to get page again, but wait a little bit between retries
      if retries < MAX_RETRIES
        code, message = e.io.status || []
        logger.warn(prog_name) { "Failed to load #{url}: Page responded with #{code || 'an unknown status'}. Retrying..." }
        sleep DELAY_BASE + (DELAY_DELTA * retries)
        retries += 1
        retry
      end

      logger.error(prog_name) { "Could not load page '#{url}': #{e.message}" }
      raise $!
    end
    page
  end

  # Runs the scraper, passing all arguments along to `#scrape()`.
  #
  # Scrapers, which `include` this module, must provide a `#scrape()` method.
  # This method invokes it, measures how long it takes, and exposes that info
  # by printing it to `stdout` and returning the scrape duration.
  #
  # @return [Float] how long scraping took, in seconds.
  def run_scraper(...)
    raise StandardError, "Failed to run scraper #{self.class}: scrape method not implemented." unless respond_to? :scrape

    start = Time.now
    scrape(...)
    stop = Time.now

    duration = stop - start
    sec = (duration % 60).truncate 2
    min = (duration / 60).floor

    logger.info(self.class) { "Finished in #{min}m #{sec}s" }
    duration
  end
end
