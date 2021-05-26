# frozen_string_literal: true

require 'uri'
require_relative '../spec_helper'
require_relative '../../app/scrapers/sections_scraper'

describe SectionsScraper do
  before do
    @scraper = described_class.new
  end

  it_behaves_like 'a scraper'

  describe '#make_query(semester, courses)' do
    context 'when called with valid input' do
      let(:actual) { @scraper.make_query('201801', ['CMSC435']) }

      it 'returns a string' do
        expect(actual).to be_a String
      end

      it 'returns a valid URL' do
        expect(actual).to match URI::DEFAULT_PARSER.make_regexp
      end
    end

    context 'when called with invalid input' do
      it 'raises an ArgumentError' do
        expect { @scraper.make_query }.to raise_error ArgumentError
        expect { @scraper.make_query(nil, ['CMSC435']) }.to raise_error ArgumentError
        expect { @scraper.make_query('201801', 'CMSC435') }.to raise_error ArgumentError
        expect { @scraper.make_query('201801', { class: 'CMSC435' }) }.to raise_error ArgumentError
      end
    end
  end

  [
    {
      courses: ['CMSC351'],
      semester: '202101'
    },
    {
      courses: %w[MATH403 BMGT289B],
      semester: '202001'
    }
  ].each do |test|
    semester = test[:semester]
    courses = test[:courses]
    url = described_class.new.make_query(semester, courses)

    describe "#parse_sections('#{url}', '#{semester}')" do
      let(:sections) do
        sections = []
        @scraper.parse_sections(url, semester) do |section|
          sections << section
        end
        sections
      end

      it 'returns a nonempty array' do
        expect(sections).to be_an Array
        expect(sections.length).to be > 0
      end

      it 'has the expected shape' do
        # a_nullish_string = (a_kind_of String) | a_nil_value

        expect(sections).to all include(
          section_id: (a_kind_of String),
          course_id: a_course_id,
          number: (a_kind_of String),
          instructors: (a_kind_of Array) & (all a_kind_of String),
          seats: (a_kind_of String),
          semester: (eq semester),
          open_seats: (a_kind_of String),
          waitlist: (a_kind_of String),
          meetings: (a_kind_of Array) & (all include(
            days: (a_kind_of String),
            room: (a_kind_of String),
            building: (a_kind_of String),
            classtype: (a_kind_of String),
            start_time: (a_kind_of String),
            end_time: (a_kind_of String),
            start_seconds: (a_kind_of Integer),
            end_seconds: (a_kind_of Integer)
          ))
        )
      end

      it "contains sections only for courses #{test[:courses].join(', ')}" do
        sections.each do |section|
          expect(courses).to include section[:course_id]
        end
      end
    end
  end

  # describe '#parse_sections(url, semester)' do
  #   let(:sections) do
  #     sections = []
  #     @scraper.parse_sections('https://app.testudo.umd.edu/soc/202101/sections?courseIds=CMSC351', '202101') do |section|
  #       sections << section
  #     end
  #     sections
  #   end
  # end
end
