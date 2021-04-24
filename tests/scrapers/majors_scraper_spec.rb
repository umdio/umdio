require 'open-uri'
require 'net/http'
require_relative '../spec_helper'
require_relative '../../app/scrapers/majors_scraper'

describe MajorsScraper, :scraper, :majors do
  before :all do
    @scraper = MajorsScraper.new
    @scraper.logger.level = Logger::WARN
  end

  # prog_name
  describe '#prog_name' do
    it 'is a string' do
      expect(@scraper.prog_name).to be_a String
    end
  end

  # url
  describe '.url' do
    let(:url) { MajorsScraper.url }
    let(:parsed) { URI.parse MajorsScraper.url }

    it 'is a string' do
      expect(url).to be_a String
    end

    it 'becomes a HTTP or HTTPS URI' do
      expect(parsed).to be_a(URI::HTTPS) | be_a(URI::HTTP)
    end

    it 'points to a valid page' do
      page = Nokogiri::HTML(url)
      expect(page).to be_a Nokogiri::HTML::Document
    end
  end

  # scrape_page
  describe '#scrape_page(page)' do
    it 'is responded to' do
      expect(@scraper).to respond_to :scrape_page
    end

    context 'the return value when passed MajorsScraper.url' do
      let(:majors) do
        page = @scraper.get_page(MajorsScraper.url, 'majors_scraper_test')
        @scraper.scrape_page(page)
      end

      it 'is an array' do
        expect(majors).to be_an Array
      end

      it 'has more than 100 entries' do
        expect(majors.length).to be > 100
      end

      context 'returned array shape' do
        it 'contains major data as hashes' do
          expect(majors).to all include(
            name: (a_kind_of String),
            college: (a_kind_of String),
            url: (a_kind_of String)
          )
        end
      end
    end
  end

  describe '#scrape()' do
    before :all do
      @scraper.scrape
      @majors = $DB[:majors]
    end

    context 'the majors table data' do
      let(:majors) { @majors.all }

      it 'contains more than 100 records' do
        expect(majors.length).to be > 100
      end

      it 'each major entry conforms to the Major model' do
        expect(majors).to all include(
          name: (a_kind_of String),
          college: (a_kind_of String),
          url: (a_kind_of String),
          major_id: (a_kind_of String)
        )
      end

      %i[name college url major_id].each do |field|
        context "each #{field} field" do
          it 'has no leading or trailing whitespace' do
            majors.each do |major|
              prop = major[field]
              expect(prop).to eq prop.strip
            end
          end

          it 'is not an empty string' do
            majors.each do |major|
              prop = major[field]
              expect(prop.strip.length).to be > 0
            end
          end
        end
      end
    end
  end
end
