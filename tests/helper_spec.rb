require_relative '../tests/spec_helper.rb'
require_relative '../app/helpers/courses_helpers.rb'
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

  end
end
