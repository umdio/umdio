require 'rspec/expectations'
require_relative '../../../app/helpers/courses_helpers'

class CourseHelpers
  extend Sinatra::UMDIO::Helpers
end

RSpec::Matchers.define :be_a_section_number do
  match do |actual|
    !!(CourseHelpers.is_section_number? actual)
  end
  description do
    "be a section number"
  end
  failure_message do |actual|
    "expected #{actual} to be a section number"
  end
  failure_message_when_negated do |actual|
    "expected #{actual} to not be a section number"
  end
end

RSpec::Matchers.define :be_a_course_id do
  match do |actual|
    !!(CourseHelpers.is_course_id? actual)
  end
  description do
    "be a course id"
  end
  failure_message do |actual|
    "expected #{actual} to be a course id"
  end
  failure_message_when_negated do |actual|
    "expected #{actual} to not be a course id"
  end
end

RSpec::Matchers.define :be_a_full_section_id do
  match do |actual|
    !!(CourseHelpers.is_full_section_id? actual)
  end
  description do
    "be a full section id"
  end
  failure_message do |actual|
    "expected #{actual} to be a full section id"
  end
  failure_message_when_negated do |actual|
    "expected #{actual} to not be a full section id"
  end
end
