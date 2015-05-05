require_relative '../../tests/spec_helper'
# TODO: make sorting spec

describe 'Pagination' do
  url = '/v0/courses'

  describe '/courses' do

    describe 'per_page' do

      it 'should not be > 100' do
        courses = get_json(url + '?per_page=1000')
        expect(courses.length).to be 100
      end

      it 'should always at least return 1 course' do
        courses = get_json(url + '?per_page=0&page=2')
        expect(courses.length).to be 1
      end

      it 'should return the number of courses requested (between 1 and 100)' do
        num = 37
        courses = get_json(url + "?per_page=#{num}")
        expect(courses.length).to be num
      end
    end

    describe 'response headers' do
      before { get url }

      # https://developer.github.com/v3/#link-header
      it 'should have a properly formatted Link' do
        expect(last_response.headers.has_key?('Link')).to be true
        match = last_response.headers['Link'].match(/<https?:\/\/[\S]+>; rel="(next|prev)"/)
        expect(match.nil?).to eq(false)
      end

      it 'should have X-Total-Count' do
        expect(last_response.headers.has_key?('X-Total-Count')).to be true
      end
    end
  end
end
