require_relative '../tests/spec_helper'

describe 'Major Endpoint' do
  url = "v0/majors"
  
  #Test to make sure majors endpoint is accessible
  describe 'get /majors' do
    it_has_behavior 'good status', url
  end
end