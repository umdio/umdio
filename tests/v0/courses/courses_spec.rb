# TODO: implement controller tests and API endpoint tests
# TODO: make extensive tests, test object structures and behaviors

require_relative '../../spec_helper.rb'

def build_url(u)
  "/v0/courses#{u}semester=201808"
end

describe 'Courses Endpoint v0' do
  describe 'Listing courses' do
    describe 'GET /courses' do
      before { get(build_url('?')) }
      it_has_behavior 'good status', (build_url '?')
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
    shared_examples_for 'gets enes100 v0' do |url|
      before { get(build_url(url)) }
      it 'returns enes100 course object' do
        course = JSON.parse(last_response.body)
        expect(course['course_id']).to eq 'ENES100'
        expect(course['name']).to eq 'Introduction to Engineering Design'
      end
    end

    describe 'returns correct object' do
      it_has_behavior 'gets enes100 v0', '/ENES100?'
    end

    describe 'returns error on misformed urls' do
      ['ene12', 'enes13', 'enes13123', 'enes100-0101', 'enes100,enes132,bmgt22'].each do |id|
        it_has_behavior 'bad status', (build_url "/#{id}?")
      end
    end

    describe 'Case insensitive' do
      it_has_behavior 'good status', (build_url '/ENES100?')
      it_has_behavior 'good status', (build_url '/enes100?')
      it_has_behavior 'good status', (build_url '/Enes100?')
      it_has_behavior 'bad status', (build_url '/abcd608a?')
    end

    describe 'get multiple courses' do
      it_has_behavior 'good status', (build_url '/ENES100,ENES102?') # doesn't check return, could very well make a good corner case
      it_has_behavior 'good status', (build_url '/ENES100,ENES102,bmgt220?')
    end

    describe 'expand query argument' do
      it 'can expand section objects' do
        get(build_url('/ENES100?expand=sections&'))
        obj = JSON.parse(last_response.body)
        expect(obj['sections'][0].is_a?(Hash)).to be(true)
      end
    end
  end

  describe 'GET /courses/<course_id>/sections' do
    describe 'Case insensitive to course_id' do
      it_has_behavior 'good status', (build_url '/ENES100/sections?')
      it_has_behavior 'good status', (build_url '/enes100/sections?')
      it_has_behavior 'good status', (build_url '/Enes100/sections?')
    end

    describe 'returns error on misformed urls' do
      it_has_behavior 'bad status', (build_url '/ene12/sections?')
      it_has_behavior 'bad status', (build_url '/enes1000/sections?')
    end
  end

  describe 'GET /courses/<course_id>/sections/<section_id>' do
    describe 'Case insensitive to course_id' do
      it_has_behavior 'good status', (build_url '/ENES100/sections/0301?')
      it_has_behavior 'good status', (build_url '/Enes100/sections/0301?')
      it_has_behavior 'good status', (build_url '/enes100/sections/0301?')
    end

    describe 'returns error on misformed urls' do
      it_has_behavior 'bad status', (build_url '/ene12/sections/0101?')
      it_has_behavior 'bad status', (build_url '/enes13/sections/01?')
      it_has_behavior 'bad status', (build_url '/enes13/sections/01011?')
      it_has_behavior 'bad status', (build_url '/enes100/sections/enes100-0101?')
      it_has_behavior 'bad status', (build_url '/enes100/sections/0101,0102,02?')
    end
  end

  describe 'GET /courses/sections/<section_id>' do
    describe 'Case insensitive' do
      it_has_behavior 'good status', (build_url '/sections/ENES100-0201?')
      it_has_behavior 'good status', (build_url '/sections/enes100-0201?')
      it_has_behavior 'good status', (build_url '/sections/Enes100-0201?')
    end

    describe 'returns error on misformed urls' do
      it_has_behavior 'bad status', (build_url '/sections/enes100?')
      it_has_behavior 'bad status', (build_url '/sections/enes100-010?')
      it_has_behavior 'bad status', (build_url '/sections/enes1000101?')
      it_has_behavior 'bad status', (build_url '/sections/enes10-0101?')
      it_has_behavior 'bad status', (build_url '/sections/ene100-0101?')
      it_has_behavior 'bad status', (build_url '/sections/enes100-0101,enes102-010?')
    end
  end
end
