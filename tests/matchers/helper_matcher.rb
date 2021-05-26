require_relative '../../app/helpers/courses_helpers'

module HelperMatchers
  extend RSpec::Matchers::DSL

  helpers = Class.new { extend Sinatra::UMDIO::Helpers }

  matcher :be_a_section_number do
    match do |actual|
      helpers.is_section_number? actual
    end

    description do
      'be a section number'
    end

    failure_message do |actual|
      "expected #{actual} to be a section number"
    end

    failure_message_when_negated do |actual|
      "expected #{actual} to not be a section number"
    end
  end

  alias_matcher :a_section_number, :be_a_section_number

  matcher :be_a_course_id do
    match do |actual|
      helpers.is_course_id? actual
    end

    description do
      'be a course id'
    end

    failure_message do |actual|
      "expected #{actual} to be a course id"
    end

    failure_message_when_negated do |actual|
      "expected #{actual} to not be a course id"
    end
  end

  alias_matcher :a_course_id, :be_a_course_id

  matcher :be_a_full_section_id do
    match do |actual|
      helpers.is_full_section_id? actual
    end

    description do
      'be a full section id'
    end

    failure_message do |actual|
      "expected #{actual} to be a full section id"
    end

    failure_message_when_negated do |actual|
      "expected #{actual} to not be a full section id"
    end
  end

  alias_matcher :a_full_section_id, :be_a_full_section_id
end
