# TODO: implement controller tests and API endpoint tests
# TODO: make extensive tests, test object structures and behaviors

require_relative '../../spec_helper.rb'

def build_url(u)
  "/v0/courses#{u}semester=201808"
end

describe 'Courses Endpoint v0' do
  describe 'Listing courses' do
    describe 'GET /courses' do
      let(:res) { JSON.parse(last_response.body) }

      include_examples 'good status', (build_url '?')

      it 'returns a list of courses' do
        course_keys = %w[course_id name dept_id credits sections]
        keys_len    = course_keys.length
        res.each do |r|
          expect((r.keys & course_keys).length).to be keys_len
        end
      end

      context 'returns a payload' do
        it 'which is an array' do
          expect(res).to be_a_kind_of Array
        end

        context 'where each course element contains the field' do
          context 'course_id which' do
            it 'is a string and a course id' do
              expect(res).to all include('course_id' => (a_kind_of String) & (be_a_course_id))
            end
          end

          context 'core which' do
            it 'is a string array' do
              expect(res).to all include('core' => (all a_kind_of String))
            end
          end

          context 'semester which' do
            it 'is an integer' do
              pending 'Schema says this is a number, but a string is returned'
              expect(res).to all include('semester' => (a_kind_of Integer))
            end

            it 'is in YYYYMM format' do
              res.each do |course|
                expect(course['semester'].to_s).to match_regex(/^[0-9]{6}$/)
              end
            end
          end

          context 'name which' do
            it 'is a string' do
              expect(res).to all include('name' => (a_kind_of String))
            end
          end

          context 'dept_id which' do
            it 'is a string' do
              expect(res).to all include('dept_id' => (a_kind_of String))
            end
          end

          context 'department which' do
            it 'is a string' do
              expect(res).to all include('department' => (a_kind_of String))
            end
          end

          context 'credits which' do
            it 'is a string' do
              expect(res).to all include('credits' => (a_kind_of String))
            end
          end

          context 'description which' do
            it 'is a string' do
              pending 'Some responses dont have descriptions, but this is not reflected in the OpenAPI spec'
              expect(res).to all include('description' => (a_kind_of String))
            end
          end

          context 'grading_method which' do
            it 'is an array containing "Regular", "Pass-Fail", "Audit", or "Sat-Fail"' do
              expect(res).to all include(
                'grading_method' => (a_kind_of Array) & (all(
                  (a_string_matching 'Regular') |
                  (a_string_matching 'Pass-Fail') |
                  (a_string_matching 'Audit') |
                  (a_string_matching 'Sat-Fail')
                ))
              )
            end
          end

          context 'gen_ed which' do
            it 'is a string array' do
              expect(res).to all include(
                'gen_ed' => (a_kind_of Array) & (all a_kind_of String)
              )
            end
          end

          context 'core which' do
            it 'is an array of core requirement strings fufilled by the course' do
              expect(res).to all include('core' => (a_kind_of Array) & (all a_kind_of String))
            end
          end

          context 'relationships which' do
            it 'exists' do
              expect(res).to all include('relationships' => a_truthy_value)
            end
          end

          context 'sections which' do
            it 'is an array of full section ids' do
              expect(res).to all include(
                'sections' => (all be_a_full_section_id)
              )
            end
          end
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

  describe 'GET /courses/list' do
    let(:res) { JSON.parse(last_response.body) }

    pending 'broken'
    include_examples 'good status', (build_url '/list?')

    it 'returns a list of minified courses' do
      expect(res).to be_a Array
      expect(res).to all include(
        'course_id' => be_a_course_id,
        'name' => (a_kind_of String)
      )
    end
  end

  # TODO these tests don't work with test_scrape but do with scrape

  # describe 'GET /courses/semesters' do
  #   let(:res) { JSON.parse(last_response.body) }

  #   include_examples 'good status', '/v0/courses/semesters'

  #   it 'returns a list of semester numbers' do
  #     pending 'OpenAPI spec says this returns a list of strings, but this actually returns a list of integers'
  #     expect(res).to be_an Array
  #     expect(res).not_to be_empty
  #     expect(res).to all be a_string_matching(/\d{6}/)
  #   end
  # end

  # describe 'GET /courses/departments' do
  #   let(:res) { JSON.parse(last_response.body) }

  #   include_examples 'good status', '/v0/courses/departments'

  #   it 'returns a list of department objects' do
  #     expect(res).to be_an Array
  #     expect(res).not_to be_empty
  #     expect(res).to all include(
  #       'dept_id' => a_string_matching(/[A-Z]{4}/),
  #       'department' => (a_kind_of String)
  #     )
  #   end

  #   [
  #     ['GVPT', 'Government and Politics'],
  #     ['ENEE', 'Electrical & Computer Engineering'],
  #     ['ARTH', 'Art History & Archaeology']
  #   ].each do |test_case|
  #     dept_id, dept_name = test_case

  #     it "includes #{dept_id}: #{dept_name}" do
  #       expect(res).to include(
  #         'dept_id' => (a_string_matching dept_id),
  #         'department' => (a_string_matching dept_name)
  #       )
  #     end
  #   end
  # end
end
