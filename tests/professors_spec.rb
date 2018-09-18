require_relative '../tests/spec_helper'

describe 'Professors Endpoint' do
  url = "v0/professors"

  describe 'get /professors' do
    it_has_behavior 'good status', url
  end

  describe 'get /professors?name=' do
    # Test for good behavior
    it_has_behavior 'good status', url + '?name=A.U. Shankar'

    # Test for TBA Instructor
    it_has_behavior 'bad status', url + '?name=Instructor: TBA'

    # Test for professor with space in name
    it_has_behavior 'bad status', url + '?name=Daniel  Contreras'

    # Test for professor with double characters
    it_has_behavior 'good status', url + '?name=Jason Filippou'
  end
end