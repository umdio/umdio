# spec/features/root_spec.rb
# we need to add tests to get coverage of all the features we have


require_relative '../tests/spec_helper'

describe 'Version 0' do
  url = '/v0' # Probably should be moved 

  describe 'Courses' do
    url = url + '/courses'
  
    describe 'GET /courses' do
      before { get url }

      it 'returns a list of courses' do
        expect(last_response.status).to eq 200
        #check the last_response.body
      end
    end

    describe 'GET /courses/list' do #same as get /courses
      before { get url + '/list'}

      it 'returns a list of courses' do
        expect(last_response.status).to eq 200
        #check the last_response.body
      end
    end

    describe 'GET /courses/<course_id>' do
      before {get url + '/ENES100' }

      it 'returns the ENES100 course' do
        expect(last_response.status).to eq 200
        #doesn't check the response body
      end
    end

    describe 'GET /courses/<course_id>+ (multiple courses)' do
      before {get url + '/ENES100,ENES102' }

      it 'returns the ENES100 and ENES102 courses' do
        expect(last_response.status).to eq 200
        #doesn't check the response body
      end
    end

    describe 'GET /courses/sections/<section_id>' do
      before {get url + '/sections/ENES100-0101'}
      it 'returns the section' do
        expect(last_response.status).to eq 200
        #need to check the response body
      end
    end

    describe 'GET /courses/<course_id>/sections' do
      before {get url + '/ENES100/sections'}
      it 'returns a list of sections' do
        expect(last_response.status).to eq 200
        #need to check the response body
      end
    end

    describe 'GET /courses/<course_id>/sections/<section_id>' do
      before {get url + '/ENES100/sections/0101'}
      it 'returns the section' do
        expect(last_response.status).to eq 200
        #need to check the response body
      end
    end

  end
end