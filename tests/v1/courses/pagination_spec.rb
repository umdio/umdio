require_relative '../../spec_helper'
require_relative 'courses_spec_helper'
# TODO: make sorting spec

describe 'Pagination v1', :endpoint, :courses do
  describe '/courses' do
    url = '/v1/courses?semester=201808'
    describe 'per_page' do
      before { get url }
      it 'should not be > 100' do
        get url + '&per_page=1000'
        res = JSON.parse(last_response.body)
        expect(res.length).to be 100
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

    describe '/courses/sections' do
      url = '/v1/courses/sections'

      describe 'with no queries' do
        before do
          get url
          @res = JSON.parse(last_response.body)
        end

        it_has_behavior 'good status', url

        it 'returns an array of courses' do
          pending
          expect(@res).to be_a_kind_of Array
          expect(@res).to all include(
            semester: (a_kind_of String),
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
              end_time: (a_kind_of String)
            )))
          )
        end
      end

      describe 'with query params' do
        context 'per_page' do
          # TODO(don): Should this return 400?
          it_has_behavior 'good status', (url + '?per_page=-5')
          it_has_behavior 'good status', (url + '?per_page=100')
          it_has_behavior 'good status', (url + '?per_page=200')

          context 'elements per page' do
            context 'returns n elements when n <= 100, 100 otherwise' do
              it 'n = 0' do
                pending
                get("#{url}?per_page=0")
                res = JSON.parse(last_response.body)
                expect(res.length).to eq 0
              end

              it 'n = 1' do
                get("#{url}?per_page=1")
                res = JSON.parse(last_response.body)
                expect(res.length).to eq 1
              end

              it 'n = 50' do
                pending 'am I doing this wrong'
                get("#{url}?per_page=50")
                res = JSON.parse(last_response.body)
                expect(res.length).to eq 50
              end

              it 'n = 100' do
                pending 'am I doing this wrong'
                get("#{url}?per_page=100")
                res = JSON.parse(last_response.body)
                expect(res.length).to eq 100
              end

              it 'n = 200' do
                pending 'am I doing this wrong'
                get("#{url}?per_page=200")
                res = JSON.parse(last_response.body)
                expect(res.length).to eq 100
              end
            end
          end
        end
      end
    end
  end
end
