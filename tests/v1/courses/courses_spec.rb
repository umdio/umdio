require_relative '../../spec_helper'

def build_url1(u)
  "/v1/courses#{u}semester=201808"
end

describe 'Courses Endpoint v1', :endpoint, :courses do
  describe 'Listing courses' do
    describe 'GET /courses' do
      before { get(build_url1('?')) }
      it_has_behavior 'good status', (build_url1 '?')
      it 'returns a list of courses' do
        res = JSON.parse(last_response.body)
        course_keys = %w[course_id name dept_id credits sections]
        keys_len    = course_keys.length
        res.each do |r|
          expect((r.keys & course_keys).length).to be keys_len
        end
      end
    end
  end

  describe 'GET /courses/<course_id>' do
    # TODO: beware of variable shadowing
    shared_examples_for 'gets enes100' do |_url|
      before { get(build_url1('/ENES100?')) }
      it 'returns enes100 course object' do
        course = JSON.parse(last_response.body)
        expect(course[0]['course_id']).to eq 'ENES100'
        expect(course[0]['name']).to eq 'Introduction to Engineering Design'
      end
    end

    describe 'returns correct object' do
      it_has_behavior 'gets enes100', (build_url1 '/ENES100?')
    end

    describe 'returns error on misformed urls' do
      ['ene12', 'enes13', 'enes13123', 'enes100-0101', 'enes100,enes132,bmgt22'].each do |id|
        it_has_behavior 'bad status', (build_url1 "/#{id}?")
      end
    end

    describe 'Case insensitive' do
      it_has_behavior 'good status', (build_url1 '/ENES100?')
      it_has_behavior 'good status', (build_url1 '/enes100?')
      it_has_behavior 'good status', (build_url1 '/Enes100?')
      it_has_behavior 'bad status', (build_url1 '/abcd608a?')
    end

    describe 'get multiple courses' do
      it_has_behavior 'good status', (build_url1 '/ENES100,ENES102?') # doesn't check return, could very well make a good corner case
      it_has_behavior 'good status', (build_url1 '/ENES100,ENES102,bmgt220?')
    end

    describe 'expand query argument' do
      it 'can expand section objects' do
        get(build_url1('/ENES100?expand=sections&'))
        obj = JSON.parse(last_response.body)
        expect(obj[0]['sections'][0].is_a?(Hash)).to be(true)
      end
    end
  end

  describe 'GET /courses/<course_id>/sections' do
    describe 'Case insensitive to course_id' do
      it_has_behavior 'good status', (build_url1 '/ENES100/sections?')
      it_has_behavior 'good status', (build_url1 '/enes100/sections?')
      it_has_behavior 'good status', (build_url1 '/Enes100/sections?')
    end

    describe 'returns error on misformed urls' do
      it_has_behavior 'bad status', (build_url1 '/ene12/sections?')
      it_has_behavior 'bad status', (build_url1 '/enes1000/sections?')
    end
  end

  describe 'GET /courses/<course_id>/sections/<section_id>' do
    describe 'Case insensitive to course_id' do
      it_has_behavior 'good status', (build_url1 '/ENES100/sections/0301?')
      it_has_behavior 'good status', (build_url1 '/Enes100/sections/0301?')
      it_has_behavior 'good status', (build_url1 '/enes100/sections/0301?')
    end

    describe 'returns error on misformed urls' do
      it_has_behavior 'bad status', (build_url1 '/ene12/sections/0101?')
      it_has_behavior 'bad status', (build_url1 '/enes13/sections/01?')
      it_has_behavior 'bad status', (build_url1 '/enes13/sections/01011?')
      it_has_behavior 'bad status', (build_url1 '/enes100/sections/enes100-0101?')
      it_has_behavior 'bad status', (build_url1 '/enes100/sections/0101,0102,02?')
    end
  end

  describe 'GET /courses/sections/<section_id>' do
    describe 'Case insensitive' do
      it_has_behavior 'good status', (build_url1 '/sections/ENES100-0201?')
      it_has_behavior 'good status', (build_url1 '/sections/enes100-0201?')
      it_has_behavior 'good status', (build_url1 '/sections/Enes100-0201?')
    end

    describe 'returns error on misformed urls' do
      it_has_behavior 'bad status', (build_url1 '/sections/enes100?')
      it_has_behavior 'bad status', (build_url1 '/sections/enes100-010?')
      it_has_behavior 'bad status', (build_url1 '/sections/enes1000101?')
      it_has_behavior 'bad status', (build_url1 '/sections/enes10-0101?')
      it_has_behavior 'bad status', (build_url1 '/sections/ene100-0101?')
      it_has_behavior 'bad status', (build_url1 '/sections/enes100-0101,enes102-010?')
    end
  end

  describe 'GET /courses/sections' do
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
