require_relative '../../spec_helper.rb'
# TODO: make sorting spec

describe 'Pagination v1', :endpoint, :courses do
  url = '/v1/courses?semester=201808'

  describe '/courses' do
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
        match = last_response.headers['Link'].match(%r{<https?://[\S]+>; rel="(next|prev)"})
        expect(match.nil?).to eq(false)
      end

      it 'should have X-Total-Count' do
        expect(last_response.headers.has_key?('X-Total-Count')).to be true
      end
    end
  end
end
