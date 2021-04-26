require_relative 'spec_helper.rb'
require_relative '../app/helpers/courses_helpers.rb'
include Sinatra::UMDIO::Helpers

describe 'Helpers' do
  describe 'Courses', :helper, :courses do
    describe 'time_to_int' do
      it 'should 10 -> 36000' do
        expect(time_to_int(10)).to be(36_000)
        expect(time_to_int(23)).to be(82_800)
        expect(time_to_int('10')).to be(36_000)
      end
      it 'should 10am -> 36000' do
        expect(time_to_int('10am')).to be(36_000)
        expect(time_to_int('11pm')).to be(82_800)
      end
      it 'should 10:00 -> 36000' do
        expect(time_to_int('10:00')).to be(36_000)
        expect(time_to_int('23:00')).to be(82_800)
      end
      it 'should 10:00am -> 36000' do
        expect(time_to_int('10:00am')).to be(36_000)
        expect(time_to_int('11:00pm')).to be(82_800)
      end
      it 'should 36000 -> 36000' do
        res = time_to_int('36000')
        expect(res).to be(36_000)
        expect(res.class).to be(Integer)
        expect(time_to_int(36_000)).to be(36_000)
      end
    end

    describe 'object ids' do
      # ! eq ! is used because of weird oddities in Ruby
      # TODO(don): elaborate on this? ^
      it 'is_section_id?' do
        {
          'CMSC131' => false,
          'CMSC131-01' => false,
          'CMSC-0101' => false,
          'CMSC131A-0113' => true,
          'CMSC131-0101' => true,
          'CMSC131-ABCD' => true
        }.each { |k, v| expect(!is_full_section_id?(k)).to eq(!v) }
      end

      it 'is_course_id?' do
        {
          'CMSC131' => true,
          'CMSC131A' => true,
          # TODO(don): this class broke the course_scraper. By definition it is a
          # valid course, and the rest of the codebase needs to be updated
          # to accommodate it.
          # 'MSBB99MB' => true,
          'BMGT' => false,
          'BMTG289N' => true,
          'CMSC131-0101' => false
        }.each { |k, v| expect(!is_course_id?(k)).to eq(!v) }
      end

      describe 'is_full_section_id?' do
        {
          'CMSC131' => false,
          'CMSC131A' => false,
          'CMSC131-0101' => true,
          'ENGL389B-0101' => true,
          'BMGT' => false,
          'BMTG289N' => false,
        }.each do |k, v|
          it "#{k} #{v ? 'is' : 'is not'} valid" do
            expect(!!is_full_section_id?(k)).to be v
          end
        end
      end

      describe 'validate_section_ids' do
        [
          {
            section_ids: ['CMSC435-0101', 'ENGL389N-0204', 'BMGT289B-0102'],
            do_halt: false,
            expected: true
          },
          {
            section_ids: ['CMSC435-0101', 'ENGL389N', 'BMGT289B-0102'],
            do_halt: false,
            expected: false
          }
        ].each do |test_case|
          section_ids = test_case[:section_ids]
          do_halt = test_case[:do_halt]
          expected = test_case[:expected]

          it "validate_section_ids([#{section_ids.join(', ')}], #{do_halt}) => #{expected}" do
            expect(validate_section_ids(section_ids, do_halt)).to be expected
          end
        end
      end
    end

  end
end
