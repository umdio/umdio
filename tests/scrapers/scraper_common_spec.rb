require 'nokogiri'
require 'open-uri'
require_relative '../spec_helper'
require_relative '../../app/scrapers/scraper_common'

# FIXME: fails with 'undefined method get_page for ScraperCommon:Module' and I'm not sure why

describe ScraperCommon, :scraper, :util do
  let(:common) { Class.new { extend ScraperCommon } }

  # get_semesters
  context '#get_semesters' do

    context '#get_semesters(["2018"])' do
      let(:actual) { common.get_semesters(['2018']) }

      it '=> ["201801", "201805", "201808", "201812"]' do
        expect(actual).to eq(%w[201801 201805 201808 201812])
      end

      it 'contains only strings' do
        expect(actual).to all be_a String
      end
    end

    context 'get_semesters(["2018", "2019", "2020"])' do
      let(:actual) { common.get_semesters(%w[2018 2019 2020]) }

      it '=> ["201801", "201805", "201808", "201812", "201901", "201905", "201908", "201912", "202001", "202005", "202008", "202012"]' do
        expect(actual).to eq(%w[201801 201805 201808 201812
                                201901 201905 201908 201912
                                202001 202005 202008 202012])
      end
      it 'contains only strings' do
        expect(actual).to all be_a String
      end
    end

    context 'when passed a single year instead of an array of years' do
      let(:actual) { common.get_semesters('2020')}
      it 'behaves the same as if a similar one-element array was passed' do
        expect(common.get_semesters('2020')).to eq(common.get_semesters(['2020']))
        expect(common.get_semesters('2018')).to eq(common.get_semesters(['2018']))
      end
      it 'may be either a number of a string' do
        expect(common.get_semesters(2019)).to eq common.get_semesters('2019')
        expect(common.get_semesters(2020)).to eq common.get_semesters('2020')
      end
    end

    context 'bad input raises an ArgumentError' do
      it 'get_semesters()' do
        expect{ common.get_semesters() }.to raise_error ArgumentError
      end
      it 'get_semesters(false)' do
        expect{ common.get_semesters(false) }.to raise_error ArgumentError
      end
      it 'get_semesters(-1)' do
        expect { common.get_semesters(-1) }.to raise_error ArgumentError
      end
      it 'get_semesters(nil)' do
        expect { common.get_semesters(nil) }.to raise_error ArgumentError
      end
      it 'get_semesters(1492)' do
        expect { common.get_semesters(1492) }.to raise_error ArgumentError
      end
      it 'get_semesters("300")' do
        expect { common.get_semesters(300) }.to raise_error ArgumentError
      end
      it 'get_semesters(2019.0)' do
        expect { common.get_semesters(2019.0) }.to raise_error ArgumentError
      end
      it 'get_semesters("Hello, world!")' do
        expect { common.get_semesters('Hello, world!') }.to raise_error ArgumentError
      end
    end
  end

  # get_page
  context '#get_page(url, prog_name)' do
    let(:valid_url) { 'https://umd.edu' }
    let(:bad_url_404) { 'https://www.cs.umd.edu/foobarbaz' }

    context 'normal behavior' do
      let(:doc) { common.get_page(valid_url, 'foo_scraper') }

      it 'returns a document' do
        expect(doc.class).to be Nokogiri::HTML::Document
      end
    end

    context 'Invalid input' do
      let(:actual) { common.get_page(bad_url_404, 'foo_scraper') }

      it 'raises an HTTPError if the URL points to a page that does not exist' do
        expect { actual }.to raise_error(OpenURI::HTTPError)
      end

      it 'requires a program name for error logging' do
        expect { common.get_page(valid_url) }.to raise_error ArgumentError
      end
    end
  end

  # logger
  context '#logger' do
    let(:logger) { common.logger }

    it 'is an instance of the built-in ruby logger' do
      expect(logger).to be_a Logger
    end

    it 'only creates one logger instance, no matter how many times it is called' do
      new_logger = common.logger
      expect(logger).to eq new_logger
    end

    it 'responds to #debug' do
      expect(logger).to respond_to :debug
    end

    it 'responds to #info' do
      expect(logger).to respond_to :info
    end

    it 'responds to #warn' do
      expect(logger).to respond_to :warn
    end
    it 'responds to #error' do
      expect(logger).to respond_to :error
    end
  end
end
# describe 'ScraperCommon' do
# end
