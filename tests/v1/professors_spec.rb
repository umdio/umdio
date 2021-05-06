require 'json'
require_relative '../spec_helper'

NAME_REGEX = /^([\w\.-]+ )+[\w\.-]+$/i.freeze

describe 'Professors Endpoint v1', :endpoint, :professors do
  url = '/v1/professors'

  describe 'get /professors' do
    before { get url }
    let(:data) { JSON.parse(last_response.body) }

    it_has_behavior 'good status', url

    it 'returns a list of professors' do
      expect(data).to all include(
        'name' => (a_string_matching NAME_REGEX),
        'taught' => (all including(
          'course_id' => a_course_id,
          'semester' => (a_kind_of String)
        ))
      )
    end
  end

  describe 'get /professors?name=' do
    # Test for good behavior
    it_has_behavior 'good status', url + '?name=A.U. Shankar'

    # Test for TBA Instructor
    it_has_behavior 'bad status', url + '?name=Instructor: TBA'

    # Test for professor with space in name
    it_has_behavior 'good status', url + '?name=Clyde  Kruskal'

    # Test for professor with double characters
    it_has_behavior 'good status', url + '?name=Jason Filippou'
  end
end
