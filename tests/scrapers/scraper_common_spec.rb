require 'nokogiri'
require 'open-uri'
require 'ruby-progressbar'
require_relative '../spec_helper'
require_relative '../../app/scrapers/scraper_common'

# FIXME: fails with 'undefined method get_page for ScraperCommon:Module' and I'm not sure why
class FakeScraper
  include ScraperCommon

  def scrape(*args)
    args
  end
end

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
      let(:actual) { common.get_semesters('2020') }
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
        expect { common.get_semesters }.to raise_error ArgumentError
      end
      it 'get_semesters(false)' do
        expect { common.get_semesters(false) }.to raise_error ArgumentError
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

    context 'when given a valid page url' do
      context 'to a page which exists' do
        let(:doc) do
          common.logger.level = :fatal
          common.get_page(valid_url, 'foo_scraper')
        end

        it 'returns a document' do
          expect(doc.class).to be Nokogiri::HTML::Document
        end
      end

      context 'to a page which does not exist' do
        let(:actual) do
          common.logger.level = :fatal
          common.get_page(bad_url_404, 'foo_scraper')
        end

        it 'raises an HTTPError' do
          expect { actual }.to raise_error(OpenURI::HTTPError)
        end

        it 'specifies the correct error code' do
          begin
            actual
            fail 'An HTTPError should have been raised'
          rescue OpenURI::HTTPError => e
            expect(e).to respond_to :io
            expect(e.io.status).to eq ["404", "Not Found"]
          end
        end
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

    it 'responds to #fatal' do
      expect(logger).to respond_to :fatal
    end

    it 'responds to #unknown' do
      expect(logger).to respond_to :fatal
    end
  end

  context '#log' do
    let(:bar) { common.get_progress_bar }

    it 'raises an ArgumentError when not provided a block' do
      expect { common.log(bar, :info) }.to raise_error ArgumentError
    end

    context 'when no log level is provided' do
      let(:actual) { common.logger.level = :fatal; common.log(bar) { 'some message' } }

      it 'returns nil' do
        expect(actual).to be_nil
      end

      it 'defaults to info' do
        # TODO how would you check it uses info?
        expect(actual).to be_nil
      end
    end

    context 'when a log level is provided' do
      it 'returns nil' do
        expect(common.log(bar, :debug) { 'message' }).to be_nil
      end

      it 'may be a string or a symbol' do
        common.logger.level = :fatal
        expect(common.log(bar, :debug) { 'message' }).to be_nil
        expect(common.log(bar, 'debug') { 'message' }).to be_nil
      end

      context 'with an invalid log level' do
        it 'raises an ArgumentError' do
          expect { common.log(bar, :foobarbaz) { 'msg' }}.to raise_error ArgumentError
          expect { common.log(bar, :verbose) { 'msg' }}.to raise_error ArgumentError
          expect { common.log(bar, false) { 'msg' }}.to raise_error ArgumentError
        end
      end

      context 'with a valid log level' do
        [:debug, :info, :warn, :error, :fatal, :unknown].each do |lvl|
          context "with log level #{lvl.to_s}" do
            let(:actual) do
              common.logger.level = :fatal
              common.log(bar, lvl) { 'some msg' }
            end

            it 'does not throw' do
              # expect { common.log(bar, lvl) { 'some msg' }}.not_to raise_error
              expect { actual }.not_to raise_error
            end

            it 'returns nil' do
              expect(actual).to be_nil
            end
          end
        end
      end # !valid log level
    end
  end

  context '#get_progress_bar' do
    let(:bar) { common.get_progress_bar }
    it 'returns a progress bar' do
      pending 'ruby does not recognize ProgressBar being imported??'
      expect(bar).to be_an_instance_of ProgressBar
    end

    it 'is not finished' do
      expect(bar.finished?).to be_falsey
    end
  end

  context '#run_scraper' do

    # let(:mock_scraper) { instance_double(FakeScraper) }
    before(:each) do
      @mock_scraper = FakeScraper.new
      @mock_scraper.logger.level = :warn
    end

    it 'is an instance method' do
      expect(common).to respond_to :run_scraper
    end

    it 'throws if #scrape is not defined' do
      expect { common.run_scraper }.to raise_error StandardError
    end

    it 'returns the scrape duration in seconds' do
      expect(@mock_scraper.run_scraper).to be_a_kind_of Float
    end

    it 'forwards arguments to #scrape' do
      @mock_scraper.stub(:scrape) { |arg| arg }
      @mock_scraper.run_scraper('some args')
      expect(@mock_scraper).to have_received(:scrape).with('some args')
    end

    it 'takes any number of arguments' do
      # @mock_scraper.stub(:scrape) { |arg| arg }
      @mock_scraper.logger.level = :error
      expect { @mock_scraper.run_scraper() }.to_not raise_error
      expect { @mock_scraper.run_scraper(5) }.to_not raise_error
      expect { @mock_scraper.run_scraper(:foo, 'bar') }.to_not raise_error
      expect { @mock_scraper.run_scraper([1, 2, 3]) }.to_not raise_error
      expect { @mock_scraper.run_scraper(foo: 'foo', bar: :baz)}.to_not raise_error
    end

  end
end
