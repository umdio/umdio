require_relative '../../spec_helper'
# TODO: make sorting spec

def sections_url(queries = '')
  "/v1/courses/sections?semester=201808#{queries}"
end

describe 'Pagination v1', :endpoint, :courses do
  describe '/courses' do
    url = '/v1/courses?semester=201808'

    describe 'per_page' do
      describe 'when set to 1000' do
        before { get url + '&per_page=1000' }
        let(:res) { last_response }
        let(:payload) { JSON.parse(last_response.body) }

        it 'still returns successfully' do
          expect(res.status).to be >= 200 and be < 300
        end

        it 'should not be > 100' do
          expect(payload.length).to eq 100
        end
      end

      it 'should always at least return 1 course' do
        get url + '&per_page=0&page=2'
        res = JSON.parse(last_response.body)
        expect(res.length).to be 1
      end

      it 'should return the number of courses requested (between 1 and 100)' do
        num = 37
        get url + "&per_page=#{num}"
        res = JSON.parse(last_response.body)
        expect(res.length).to be num
      end
    end

    describe 'response headers' do
      before { get url }

      # https://developer.github.com/v3/#link-header
      it 'should have a properly formatted Link' do
        expect(last_response.headers.has_key?('Link')).to be true
        match = last_response.headers['Link'].match(%r{<https?://\S+>; rel="(next|prev)"})
        expect(match.nil?).to eq(false)
      end

      it 'should have X-Total-Count' do
        expect(last_response.headers.has_key?('X-Total-Count')).to be true
      end
    end
  end

  describe '/courses/sections' do

    describe 'with no queries' do
      let(:res) { JSON.parse(last_response.body) }

      include_examples 'good status', sections_url

      it 'returns an array of sections' do
        pending
        expect(res).to be_a_kind_of Array
        expect(res).to all include(
          semester: (a_kind_of String),
          course: be_a_course_id,
          number: (a_kind_of String),
          seats: (a_kind_of String),
          open_seats: (a_kind_of String),
          waitlist: (a_kind_of String),
          instructors: (all a_kind_of String),
          meetings: (a_kind_of(Array) & (all include(
            days: (a_kind_of String),
            room: (a_kind_of String),
            building: (a_kind_of String),
            classtype: (a_kind_of String),
            start_time: (a_kind_of String),
            end_time: (a_kind_of String)
          )))
        )
      end
    end

    describe 'with query params' do
      context 'when per_page is set' do
        let(:res) { JSON.parse(last_response.body) }

        describe 'with a value of 0' do

          include_examples 'good status', sections_url('&per_page=0')

          it 'returns successfully' do
            expect(last_response.status).to be 200
          end

          it 'returns 1 section' do
            expect(res.length).to be 1
          end
        end

        describe 'with a value between 1 and 100' do
          num = 5
          include_examples 'good status', sections_url("&per_page=#{num}")

          it 'returns that many sections' do
            expect(res.length).to be num
          end
        end

        describe 'with a value over 100' do
          before { get sections_url('&per_page=1000') }

          include_examples 'good status', sections_url('&per_page=1000')

          it 'only returns 100 elements' do
            expect(res.length).to be 100
          end
        end
      end
    end
  end
end
