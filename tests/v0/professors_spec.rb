require_relative '../spec_helper'

NAME_REGEX = /^([\w\.-]+ )+[\w\.-]+$/i.freeze

describe 'Professors Endpoint v0' do
  url = '/v0/professors'

  describe 'get /professors' do
    let(:data) { JSON.parse(last_response.body) }

    include_examples 'good status', url + '?semester=201808'

    it 'returns a list of professors' do
      expect(data).to all include(
        'name' => (a_string_matching NAME_REGEX),
        'courses' => (all be_a_course_id),
        'department' => (all a_kind_of String),
        'semester' => (all a_kind_of String)
      )
    end
  end

  describe 'get /professors?name=' do
    # Test for good behavior
    it_has_behavior 'good status', url + '?name=A.U. Shankar&semester=201808'

    # Test for TBA Instructor
    it_has_behavior 'bad status', url + '?name=Instructor: TBA&semester=201808'

    # Test for professor with space in name
    it_has_behavior 'good status', url + '?name=Clyde  Kruskal&semester=201808'

    # Test for professor with double characters
    it_has_behavior 'good status', url + '?name=Jason Filippou&semester=201808'
  end
end
