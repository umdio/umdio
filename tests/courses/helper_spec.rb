require_relative '../../tests/spec_helper.rb'
require_relative '../../app/helpers/courses_helpers.rb'
include Sinatra::UMDIO::Helpers

describe 'Helpers' do
  describe 'Courses' do

    describe 'time_to_int' do
      it 'should 10 -> 36000' do
        expect(time_to_int(10)).to be(36000)
        expect(time_to_int(23)).to be(82800)
        expect(time_to_int('10')).to be(36000)
      end
      it 'should 10am -> 36000' do
        expect(time_to_int('10am')).to be(36000)
        expect(time_to_int('11pm')).to be(82800)
      end
      it 'should 10:00 -> 36000' do
        expect(time_to_int('10:00')).to be(36000)
        expect(time_to_int('23:00')).to be(82800)
      end
      it 'should 10:00am -> 36000' do
        expect(time_to_int('10:00am')).to be(36000)
        expect(time_to_int('11:00pm')).to be(82800)
      end
      it 'should 36000 -> 36000' do
        res = time_to_int('36000')
        expect(res).to be(36000)
        expect(res.class).to be(Fixnum)
        expect(time_to_int(36000)).to be(36000)
      end
    end

    describe 'object ids' do
      # ! eq ! is used because of weird oddities in Ruby
      it 'is_section_id?' do
        {
          'CMSC131' => false,
          'CMSC131-01' => false,
          'CMSC-0101' => false,
          'CMSC131A-0113' => true,
          'CMSC131-0101' => true,
          'CMSC131-ABCD' => true
        }.each { |k,v| expect(!is_full_section_id?(k)).to eq(!v) }
      end

      it 'is_course_id?' do
        {
          'CMSC131' => true,
          'CMSC131A' => true,
          'BMGT' => false,
          'CMSC131-0101' => false
        }.each { |k,v| expect(!is_course_id?(k)).to eq(!v) }
      end
    end

  end
end
