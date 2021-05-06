require 'uri'
require_relative '../spec_helper'
require_relative '../../app/scrapers/courses_scraper'

describe CoursesScraper do
  # let(:scraper) { CoursesScraper.new }
  before :each do
    @scraper = CoursesScraper.new
  end

  it_behaves_like 'a scraper'

  describe '#utf_safe(text)' do
    before :all do
      @text = 'hi, mom!'
    end

    # let(:actual) { scraper.utf_safe text }

    context 'when given a UTF-8 encoded string' do
      it 'has no effect' do
        expect(@text.encoding).to be Encoding::UTF_8
        expect(@scraper.utf_safe(@text)).to be @text
      end
    end

    context 'when given a non-UTF-8 encoded string' do
      context 'when the encoding is valid' do
        let(:actual) { @scraper.utf_safe(@text.encode(Encoding::ISO_8859_1)) }

        it 'has no effect' do
          expect(actual.encoding).to be Encoding::ISO_8859_1
          expect(actual).to eq @text
        end
      end

      context 'when the encoding is not valid' do
        before :all do
          @text = "\xc2".force_encoding('UTF-8')
          expect(@text.valid_encoding?).to be_falsey
        end

        let(:actual) { @scraper.utf_safe @text }

        it 'result is encoded with UTF-8' do
          expect(actual.encoding).to be Encoding::UTF_8
        end

        it 'result has a valid encoding' do
          expect(actual.valid_encoding?).to be_truthy
        end

        it 'replaces invalid characters with the empty string' do
          expect(actual).to eq ''
        end
      end
    end
  end

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
      expect(urls).to all match URI::regexp
    end
  end
end
