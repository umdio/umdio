# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Professors Endpoint' do
  url = 'v0/professors'

  describe 'get /professors' do
    it_has_behavior 'good status', "#{url}?semester=201808"
  end

  describe 'get /professors?name=' do
    # Test for good behavior
    it_has_behavior 'good status', "#{url}?name=A.U. Shankar&semester=201808"

    # Test for TBA Instructor
    it_has_behavior 'bad status', "#{url}?name=Instructor: TBA&semester=201808"

    # Test for professor with space in name
    it_has_behavior 'good status', "#{url}?name=Clyde  Kruskal&semester=201808"

    # Test for professor with double characters
    it_has_behavior 'good status', "#{url}?name=Jason Filippou&semester=201808"
  end
end
