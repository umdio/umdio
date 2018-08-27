require_relative '../tests/spec_helper'

describe 'Professors Endpoint' do
  url = "v0/professors"

  shared_examples_for 'good status' do |url|
    before {get url}
    it 'has a good response' do
      expect(last_response.status).to be == 200
      expect(last_response.body.length).to be > 1
    end
  end

  describe 'get /professors' do
    it_has_behavior 'good status', url
  end

  describe 'get /professors?name=' do
    it_has_behavior 'good status', url + '?name=A.U. Shankar'
    it 'get /professors?name=Instructor: TBA returns nothing' do
        res = get url + '?name=Instructor: TBA'
        expect(JSON.parse(res.body)).to eq([])
    end
  end
end