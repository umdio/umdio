require_relative '../tests/spec_helper'

describe 'Professors Endpoint' do
  url = "v0/professors"

  describe 'get /professors' do
    it_has_behavior 'good status', url
  end

  describe 'get /professors?name=' do
    it_has_behavior 'good status', url + '?name=A.U. Shankar'
    it 'get /professors?name=Instructor: TBA returns nothing' do
        res = get url + '?name=Instructor: TBA'
        expect(JSON.parse(res.body)).to eq([])
    end

    it 'get /profesors?name=Daniel  Contreras returns nothing' do
      res = get url + '?name=Daniel  Contreras'
      expect(JSON.parse(res.body)).to eq([])
    end

  end

end