require 'uri'
require_relative '../spec_helper'
require_relative '../../app/scrapers/courses_scraper'

describe CoursesScraper do
  # let(:scraper) { CoursesScraper.new }
  before :each do
    @scraper = CoursesScraper.new
  end

  it_behaves_like 'a scraper'

  describe '#get_department_urls' do
    let :urls do
      allow(@scraper).to receive(:semesters) { ['201801'] }
      allow(@scraper).to receive(:get_progress_bar) { double('progress bar').as_null_object }
      @scraper.get_department_urls
    end

    it 'returns an array of strings' do
      # allow(@scraper).to receive(:semesters) { ['201801'] }
      expect(urls).to be_a Array
      expect(urls).to all be_a String
    end

    it 'each department url is a valid uri' do
      expect(urls).to all match URI::DEFAULT_PARSER.make_regexp
    end
  end
end
